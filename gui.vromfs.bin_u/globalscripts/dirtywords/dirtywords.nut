from "auth_wt" import getCountryCode
from "%globalScripts/logs.nut" import *
from "%sqstd/string.nut" import utf8ToLower

//
// Dirty Words checker.
//
// Usage:
// checkPhrase("Полный пиздец, почему-то не работают блядские закрылки!")
// Result: "Полный ******, почему-то не работают ******** закрылки!"
// checkPhrase("Why did you fucking shot me, bastard?")
// Result: "Why did you ******* shot me, *******?"
// checkPhrase("我们要他妈敌方队伍")
// Result: "我们要****敌方队伍"
// checkPhrase("何かがおかしい慰安婦フラップが壊れています")
// Result: "何かがおかしい******フラップが壊れています"
//

let regexp2 = require("regexp2")
let utf8 = require("utf8")

local debugLogFunc = null

let dict = {
  excludesdata    = null
  excludescore    = null
  foulcore        = null
  fouldata        = null
  badphrases      = null
  badcombination  = null
}

let dictAsian = {
  badsegments           = {}
  forbiddennamesegments = {}
}

local pendingDict = null
local pendingDictAsian = null

let toRegexpFunc = {
  default = @(str) regexp2(str)
  badcombination = @(str) regexp2("".concat("(", "\\s".join(str.split(" ").filter(@(w) w != "")), ")"))
}

function updateAsianDict(lookupTbl, upd) {
  foreach (k, v in upd) {
    if (k not in lookupTbl)
      lookupTbl[k] <- []
    lookupTbl[k].extend(v.filter(@(w) !lookupTbl[k].contains(w)))
  }
}

// Collect language tables
function init(langSources) {
  let myLocation = getCountryCode()
  let isMyLocationKnown = myLocation != "" // is true only after login
  foreach (varName, _val in dict) {
    dict[varName] = []
    let mkRegexp = toRegexpFunc?[varName] ?? toRegexpFunc.default
    foreach (source in langSources) {
      foreach (vSrc in (source?[varName] ?? [])) {
        local v
        local hasRegions = false
        let tVSrc = type(vSrc)
        if (tVSrc == "string")
          v = mkRegexp(vSrc)
        else if (tVSrc == "table") {
          hasRegions = "regions" in vSrc
          if (hasRegions && isMyLocationKnown && !vSrc.regions.contains(myLocation))
            continue
          v = clone vSrc
          if ("value" in v)
            v.value = mkRegexp(v.value)
          if ("arr" in v)
            v.arr = v.arr.map(@(av) mkRegexp(av))
         }
        else
          assert(false, "Wrong var type in DirtyWordsFilter config")

        let isPending = hasRegions && !isMyLocationKnown
        if (!isPending)
          dict[varName].append(v)
        else {
          pendingDict = pendingDict ?? {}
          if (varName not in pendingDict)
            pendingDict[varName] <- []
          pendingDict[varName].append(v)
        }
      }
    }
  }

  foreach (varName, collection in dictAsian) {
    foreach (source in langSources) {
      foreach (cfg in (source?[varName] ?? {})) {
        let { regions = null, list = {} } = cfg
        local hasRegions = regions != null
        if (hasRegions && isMyLocationKnown && !regions.contains(myLocation))
          continue
        let isPending = hasRegions && !isMyLocationKnown
        if (!isPending)
          updateAsianDict(collection, list)
        else {
          pendingDictAsian = pendingDictAsian ?? {}
          if (varName not in pendingDictAsian)
            pendingDictAsian[varName] <- []
          pendingDictAsian[varName].append(cfg)
        }
      }
    }
  }

  foreach (source in langSources)
    source.clear()
}

function continueInitAfterLogin() {
  let myLocation = getCountryCode()
  if (myLocation == "")
    return
  if (pendingDict != null) {
    foreach (varName, val in pendingDict)
      foreach (v in val)
        if (v.regions.contains(myLocation))
          dict[varName].append(v)
    pendingDict = null
  }
  if (pendingDictAsian != null) {
    foreach (varName, val in pendingDictAsian)
      foreach (v in val)
        if (v.regions.contains(myLocation))
          updateAsianDict(dictAsian[varName], v.list)
    pendingDictAsian = null
  }
}

let preparereplace = [
  {
    pattern = regexp2(@"[\'\-\+\;\.\,\*\?\(\)]")
    replace = " "
  },
  {
    pattern = regexp2(@"[\!\:\_]")
    replace = " "
  }
];


let prepareex = regexp2("(а[х]?)|(в)|([вмт]ы)|(д[ао])|(же)|(за)")


let prepareword = [
  {
    pattern = regexp2("ё")
    replace = "е"
  },
  {
    pattern = regexp2(@"&[Ee][Uu][Mm][Ll];")
    replace = "е"
  },
  {
    pattern = regexp2("&#203;")
    replace = "е"
  },
  {
    pattern = regexp2(@"&[Cc][Ee][Nn][Tt];")
    replace = "с"
  },
  {
    pattern = regexp2("&#162;")
    replace = "с"
  },
  {
    pattern = regexp2("&#120;")
    replace = "х"
  },
  {
    pattern = regexp2("&#121;")
    replace = "у"
  },
  {
    pattern = regexp2(@"\|\/\|")
    replace = "и"
  },
  {
    pattern = regexp2(@"3[\.\,]14[\d]{0,}")
    replace = "пи"
  },
  {
    pattern = regexp2(@"[\'\-\+\;\.\,\*\?\(\)]")
    replace = ""
  },
  {
    pattern = regexp2(@"[\!\:\_]")
    replace = ""
  },
  {
    pattern = regexp2(@"[u]{3,}")
    replace = "u"
  }
];


let preparewordwhile = {
  pattern = regexp2(@"(.)\\1\\1")
  replace = "\\1\\1"
}

function preparePhrase(text) {
  local phrase = text
  let buffer = []

  foreach (p in preparereplace)
    phrase = p.pattern.replace(p.replace, phrase)

  let words = phrase.split(" ")

  let out = []

  foreach (w in words) {
    if (w.len() < 3 && ! prepareex.match(w)) {
      buffer.append(w)
    }
    else {
      if (buffer.len()) {
        out.append("".join(buffer))
        buffer.clear()
      }

      out.append(w)
    }
  }

  if (buffer.len())
    out.append("".join(buffer))

  return out
}

function prepareWord(word) {
  // convert to lower
  word = utf8ToLower(word.strip())

  // replaces
  foreach (p in prepareword)
    word = p.pattern.replace(p.replace, word)

  local post = null

  while (word != post) {
    post = word
    word = preparewordwhile.pattern.replace(preparewordwhile.replace, word)
  }

  return word
}

function checkRegexps(word, regexps, accuse) {
  foreach (reg in regexps)
    if ((reg?.value ?? reg).match(word)) {
      debugLogFunc?($"DirtyWordsFilter: Word \"{word}\" matched pattern \"{(reg?.value ?? reg).pattern()}\"")
      return !accuse
    }
  return accuse
}

// Checks that one word is correct.
function checkWord(word) {
  word = prepareWord(word)

  local status = true
  let fl = utf8(word).slice(0, 1)

  if (status)
    status = checkRegexps(word, dict.foulcore, true)

  if (status)
    foreach (section in dict.fouldata)
      if (section.key == fl)
        status = checkRegexps(word, section.arr, true)

  if (status)
    status = checkRegexps(word, dict.badphrases, true)

  if (!status)
    status = checkRegexps(word, dict.excludescore, false)

  if (!status)
    foreach (section in dict.excludesdata)
      if (section.key == fl)
        status = checkRegexps(word, section.arr, false)

  return status
}

function getUnicodeCharsArray(str) {
  let res = []
  let utfStr = utf8(str)
  for (local i = 0; i < utfStr.charCount(); i++) {
    let char = utfStr.slice(i, i + 1)
    res.append(char)
  }
  return res
}

function getMaskedWord(w, maskChar = "*") {
  return "".join(array(utf8(w).charCount(), maskChar))
}

function checkPhraseInternal(text, isName) {
  local phrase = text

  // In Asian languages, there is no spaces to separate words.
  local maskChars = null
  let charsArray = getUnicodeCharsArray(phrase)
  foreach (char in charsArray) {
    let segmentsLists = [
      dictAsian.badsegments?[char] ?? []
      isName ? (dictAsian.forbiddennamesegments?[char] ?? []) : []
    ]
    foreach (segmentsList in segmentsLists) {
      foreach (segment in segmentsList) {
        if (!phrase.contains(segment))
          continue
        debugLogFunc?($"DirtyWordsFilter: Phrase contains segment \"{segment}\"")

        let utfPhrase = utf8(phrase)
        maskChars = maskChars ?? array(utfPhrase.charCount(), false)
        let length = utf8(segment).charCount()
        local startIdx = 0
        while (true) {
          let idx = utfPhrase.indexof(segment, startIdx)
          if (idx == null)
            break
          for (local i = idx; i < idx + length; i++) // -w200
            maskChars[i] = true
          startIdx = idx + length
        }
      }
    }
  }
  if (maskChars != null)
    phrase = "".join(charsArray.map(@(c, i) maskChars[i] ? "**" : c))

  local lowerPhrase = utf8ToLower(phrase)
  //To match a whole combination of words
  foreach (pattern in dict.badcombination)
    if (pattern.match(lowerPhrase)) {
      debugLogFunc?($"DirtyWordsFilter: Phrase matched pattern \"{pattern.pattern()}\"")
      let word = pattern.multiExtract("\\1", lowerPhrase)?[0] ?? ""
      phrase = pattern.replace(getMaskedWord(word), lowerPhrase)
      lowerPhrase = utf8ToLower(phrase)
    }

  let words = preparePhrase(phrase)

  foreach (w in words)
    if (!checkWord(w))
      phrase = regexp2(w).replace(getMaskedWord(w), phrase)

  return phrase
}

// Returns censored version of phrase.
let checkPhrase = @(text) checkPhraseInternal(text, false)

// Checks that phrase is correct.
let isPhrasePassing = @(text) checkPhrase(text) == text

// Returns censored version of username.
let checkName = @(name) checkPhraseInternal(name, true)

// Checks that username is correct.
let isNamePassing = @(name) checkName(name) == name

// Set debug logging func to enable debug mode, or null to disable it.
function setDebugLogFunc(funcOrNull) {
  debugLogFunc = funcOrNull
}

// This func is for binding a text checking console command, like:
// register_command(@(text) debugDirtyWordsFilter(text, false, console_print), "debug.dirty_words_filter.phrase")
// register_command(@(text) debugDirtyWordsFilter(text, true,  console_print), "debug.dirty_words_filter.name")
function debugDirtyWordsFilter(text, isName, temporaryDebugLogFunc) {
  let isPassing = (isName ? isNamePassing : isPhrasePassing)(text)
  local prevLogFunc = null
  if (!isPassing) {
    prevLogFunc = debugLogFunc
    debugLogFunc = temporaryDebugLogFunc
  }
  let censoredResult = (isName ? checkName : checkPhrase)(text)
  if (!isPassing)
    debugLogFunc = prevLogFunc
  temporaryDebugLogFunc("".concat(isPassing ? "(CLEAN)" : "(DIRTY)", " \"", censoredResult, "\""))
}

return {
  init
  continueInitAfterLogin
  checkPhrase
  isPhrasePassing
  checkName
  isNamePassing
  setDebugLogFunc
  debugDirtyWordsFilter
}

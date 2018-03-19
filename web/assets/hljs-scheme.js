// Highlight.js, modified to allow builtins to be specified at runtime.
//
// Highlight.js is Copyright 2006, Ivan Sagalaev and has been released under the
// 3-clause BSD License at https://github.com/isagalaev/highlight.js/blob/master/LICENSE
function hljsRegister(BUILTINS) {
hljs.registerLanguage("scheme", function(hljs) {
  var SCHEME_IDENT_RE = '[^\\(\\)\\[\\]\\{\\}",\'`;#|\\\\\\s]+';
  var SCHEME_SIMPLE_NUMBER_RE = '(\\-|\\+)?\\d+([./]\\d+)?';
  var SCHEME_COMPLEX_NUMBER_RE = SCHEME_SIMPLE_NUMBER_RE + '[+\\-]' + SCHEME_SIMPLE_NUMBER_RE + 'i';

  var SHEBANG = {
    className: 'meta',
    begin: '^#!',
    end: '$'
  };

  var LITERAL = {
    className: 'literal',
    begin: '(#t|#f|#\\\\' + SCHEME_IDENT_RE + '|#\\\\.)'
  };

  var NUMBER = {
    className: 'number',
    variants: [
      { begin: SCHEME_SIMPLE_NUMBER_RE, relevance: 0 },
      { begin: SCHEME_COMPLEX_NUMBER_RE, relevance: 0 },
      { begin: '#b[0-1]+(/[0-1]+)?' },
      { begin: '#o[0-7]+(/[0-7]+)?' },
      { begin: '#x[0-9a-f]+(/[0-9a-f]+)?' }
    ]
  };

  var STRING = hljs.QUOTE_STRING_MODE;

  var REGULAR_EXPRESSION = {
    className: 'regexp',
    begin: '#[pr]x"',
    end: '[^\\\\]"'
  };

  var COMMENT_MODES = [
    hljs.COMMENT(
      ';',
      '$',
      {
        relevanOMMENTe: 0
      }
    ),
    hljs.COMMENT('#\\|', '\\|#')
  ];

  var IDENT = {
    begin: SCHEME_IDENT_RE,
    relevance: 0
  };

  var QUOTED_IDENT = {
    className: 'symbol',
    begin: '\'' + SCHEME_IDENT_RE
  };

  var BODY = {
    endsWithParent: true,
    relevance: 0
  };

  var QUOTED_LIST = {
    begin: /'/,
    contains: [
      {
        begin: '\\(', end: '\\)',
        contains: ['self', LITERAL, STRING, NUMBER, IDENT, QUOTED_IDENT]
      }
    ]
  };

  var NAME = {
    className: 'name',
    begin: SCHEME_IDENT_RE,
    lexemes: SCHEME_IDENT_RE,
    keywords: BUILTINS
  };

  var LAMBDA = {
    begin: /lambda/, endsWithParent: true, returnBegin: true,
    contains: [
      NAME,
      {
        begin: /\(/, end: /\)/, endsParent: true,
        contains: [IDENT],
      }
    ]
  };

  var LIST = {
    variants: [
      { begin: '\\(', end: '\\)' },
      { begin: '\\[', end: '\\]' }
    ],
    contains: [LAMBDA, NAME, BODY]
  };

  BODY.contains = [LITERAL, NUMBER, STRING, IDENT, QUOTED_IDENT, QUOTED_LIST, LIST].concat(COMMENT_MODES);

  return {
    illegal: /\S/,
    contains: [SHEBANG, NUMBER, STRING, QUOTED_IDENT, QUOTED_LIST, LIST].concat(COMMENT_MODES)
  };
});
}
!function(e){var n="object"==typeof window&&window||"object"==typeof self&&self;"undefined"!=typeof exports?e(exports):n&&(n.hljs=e({}),"function"==typeof define&&define.amd&&define([],function(){return n.hljs}))}(function(e){function n(e){return e.replace(/&/gm,"&amp;").replace(/</gm,"&lt;").replace(/>/gm,"&gt;")}function t(e){return e.nodeName.toLowerCase()}function r(e,n){var t=e&&e.exec(n);return t&&0==t.index}function a(e){return/^(no-?highlight|plain|text)$/i.test(e)}function i(e){var n,t,r,i=e.className+" ";if(i+=e.parentNode?e.parentNode.className:"",t=/\blang(?:uage)?-([\w-]+)\b/i.exec(i))return _(t[1])?t[1]:"no-highlight";for(i=i.split(/\s+/),n=0,r=i.length;r>n;n++)if(_(i[n])||a(i[n]))return i[n]}function s(e,n){var t,r={};for(t in e)r[t]=e[t];if(n)for(t in n)r[t]=n[t];return r}function o(e){var n=[];return function r(e,a){for(var i=e.firstChild;i;i=i.nextSibling)3==i.nodeType?a+=i.nodeValue.length:1==i.nodeType&&(n.push({event:"start",offset:a,node:i}),a=r(i,a),t(i).match(/br|hr|img|input/)||n.push({event:"stop",offset:a,node:i}));return a}(e,0),n}function l(e,r,a){function i(){return e.length&&r.length?e[0].offset!=r[0].offset?e[0].offset<r[0].offset?e:r:"start"==r[0].event?e:r:e.length?e:r}function s(e){function r(e){return" "+e.nodeName+'="'+n(e.value)+'"'}u+="<"+t(e)+Array.prototype.map.call(e.attributes,r).join("")+">"}function o(e){u+="</"+t(e)+">"}function l(e){("start"==e.event?s:o)(e.node)}for(var c=0,u="",g=[];e.length||r.length;){var f=i();if(u+=n(a.substr(c,f[0].offset-c)),c=f[0].offset,f==e){g.reverse().forEach(o);do l(f.splice(0,1)[0]),f=i();while(f==e&&f.length&&f[0].offset==c);g.reverse().forEach(s)}else"start"==f[0].event?g.push(f[0].node):g.pop(),l(f.splice(0,1)[0])}return u+n(a.substr(c))}function c(e){function n(e){return e&&e.source||e}function t(t,r){return new RegExp(n(t),"m"+(e.case_insensitive?"i":"")+(r?"g":""))}function r(a,i){if(!a.compiled){if(a.compiled=!0,a.keywords=a.keywords||a.beginKeywords,a.keywords){var o={},l=function(n,t){e.case_insensitive&&(t=t.toLowerCase()),t.split(" ").forEach(function(e){var t=e.split("|");o[t[0]]=[n,t[1]?Number(t[1]):1]})};"string"==typeof a.keywords?l("keyword",a.keywords):Object.keys(a.keywords).forEach(function(e){l(e,a.keywords[e])}),a.keywords=o}a.lexemesRe=t(a.lexemes||/\b\w+\b/,!0),i&&(a.beginKeywords&&(a.begin="\\b("+a.beginKeywords.split(" ").join("|")+")\\b"),a.begin||(a.begin=/\B|\b/),a.beginRe=t(a.begin),a.end||a.endsWithParent||(a.end=/\B|\b/),a.end&&(a.endRe=t(a.end)),a.terminator_end=n(a.end)||"",a.endsWithParent&&i.terminator_end&&(a.terminator_end+=(a.end?"|":"")+i.terminator_end)),a.illegal&&(a.illegalRe=t(a.illegal)),void 0===a.relevance&&(a.relevance=1),a.contains||(a.contains=[]);var c=[];a.contains.forEach(function(e){e.variants?e.variants.forEach(function(n){c.push(s(e,n))}):c.push("self"==e?a:e)}),a.contains=c,a.contains.forEach(function(e){r(e,a)}),a.starts&&r(a.starts,i);var u=a.contains.map(function(e){return e.beginKeywords?"\\.?("+e.begin+")\\.?":e.begin}).concat([a.terminator_end,a.illegal]).map(n).filter(Boolean);a.terminators=u.length?t(u.join("|"),!0):{exec:function(){return null}}}}r(e)}function u(e,t,a,i){function s(e,n){for(var t=0;t<n.contains.length;t++)if(r(n.contains[t].beginRe,e))return n.contains[t]}function o(e,n){if(r(e.endRe,n)){for(;e.endsParent&&e.parent;)e=e.parent;return e}return e.endsWithParent?o(e.parent,n):void 0}function l(e,n){return!a&&r(n.illegalRe,e)}function f(e,n){var t=h.case_insensitive?n[0].toLowerCase():n[0];return e.keywords.hasOwnProperty(t)&&e.keywords[t]}function d(e,n,t,r){var a=r?"":R.classPrefix,i='<span class="'+a,s=t?"":"</span>";return i+=e+'">',i+n+s}function E(){if(!M.keywords)return n(y);var e="",t=0;M.lexemesRe.lastIndex=0;for(var r=M.lexemesRe.exec(y);r;){e+=n(y.substr(t,r.index-t));var a=f(M,r);a?(S+=a[1],e+=d(a[0],n(r[0]))):e+=n(r[0]),t=M.lexemesRe.lastIndex,r=M.lexemesRe.exec(y)}return e+n(y.substr(t))}function v(){var e="string"==typeof M.subLanguage;if(e&&!N[M.subLanguage])return n(y);var t=e?u(M.subLanguage,y,!0,x[M.subLanguage]):g(y,M.subLanguage.length?M.subLanguage:void 0);return M.relevance>0&&(S+=t.relevance),e&&(x[M.subLanguage]=t.top),d(t.language,t.value,!1,!0)}function p(){O+=void 0!==M.subLanguage?v():E(),y=""}function m(e,n){O+=e.className?d(e.className,"",!0):"",M=Object.create(e,{parent:{value:M}})}function b(e,n){if(y+=e,void 0===n)return p(),0;var t=s(n,M);if(t)return t.skip?y+=n:(t.excludeBegin&&(y+=n),p(),t.returnBegin||t.excludeBegin||(y=n)),m(t,n),t.returnBegin?0:n.length;var r=o(M,n);if(r){var a=M;a.skip?y+=n:(a.returnEnd||a.excludeEnd||(y+=n),p(),a.excludeEnd&&(y=n));do M.className&&(O+="</span>"),M.skip||(S+=M.relevance),M=M.parent;while(M!=r.parent);return r.starts&&m(r.starts,""),a.returnEnd?0:n.length}if(l(n,M))throw new Error('Illegal lexeme "'+n+'" for mode "'+(M.className||"<unnamed>")+'"');return y+=n,n.length||1}var h=_(e);if(!h)throw new Error('Unknown language: "'+e+'"');c(h);var w,M=i||h,x={},O="";for(w=M;w!=h;w=w.parent)w.className&&(O=d(w.className,"",!0)+O);var y="",S=0;try{for(var C,L,A=0;;){if(M.terminators.lastIndex=A,C=M.terminators.exec(t),!C)break;L=b(t.substr(A,C.index-A),C[0]),A=C.index+L}for(b(t.substr(A)),w=M;w.parent;w=w.parent)w.className&&(O+="</span>");return{relevance:S,value:O,language:e,top:M}}catch(B){if(-1!=B.message.indexOf("Illegal"))return{relevance:0,value:n(t)};throw B}}function g(e,t){t=t||R.languages||Object.keys(N);var r={relevance:0,value:n(e)},a=r;return t.forEach(function(n){if(_(n)){var t=u(n,e,!1);t.language=n,t.relevance>a.relevance&&(a=t),t.relevance>r.relevance&&(a=r,r=t)}}),a.language&&(r.second_best=a),r}function f(e){return R.tabReplace&&(e=e.replace(/^((<[^>]+>|\t)+)/gm,function(e,n){return n.replace(/\t/g,R.tabReplace)})),R.useBR&&(e=e.replace(/\n/g,"<br>")),e}function d(e,n,t){var r=n?w[n]:t,a=[e.trim()];return e.match(/\bhljs\b/)||a.push("hljs"),-1===e.indexOf(r)&&a.push(r),a.join(" ").trim()}function E(e){var n=i(e);if(!a(n)){var t;R.useBR?(t=document.createElementNS("http://www.w3.org/1999/xhtml","div"),t.innerHTML=e.innerHTML.replace(/\n/g,"").replace(/<br[ \/]*>/g,"\n")):t=e;var r=t.textContent,s=n?u(n,r,!0):g(r),c=o(t);if(c.length){var E=document.createElementNS("http://www.w3.org/1999/xhtml","div");E.innerHTML=s.value,s.value=l(c,o(E),r)}s.value=f(s.value),e.innerHTML=s.value,e.className=d(e.className,n,s.language),e.result={language:s.language,re:s.relevance},s.second_best&&(e.second_best={language:s.second_best.language,re:s.second_best.relevance})}}function v(e){R=s(R,e)}function p(){if(!p.called){p.called=!0;var e=document.querySelectorAll("pre code");Array.prototype.forEach.call(e,E)}}function m(){addEventListener("DOMContentLoaded",p,!1),addEventListener("load",p,!1)}function b(n,t){var r=N[n]=t(e);r.aliases&&r.aliases.forEach(function(e){w[e]=n})}function h(){return Object.keys(N)}function _(e){return e=(e||"").toLowerCase(),N[e]||N[w[e]]}var R={classPrefix:"hljs-",tabReplace:null,useBR:!1,languages:void 0},N={},w={};return e.highlight=u,e.highlightAuto=g,e.fixMarkup=f,e.highlightBlock=E,e.configure=v,e.initHighlighting=p,e.initHighlightingOnLoad=m,e.registerLanguage=b,e.listLanguages=h,e.getLanguage=_,e.inherit=s,e.IDENT_RE="[a-zA-Z]\\w*",e.UNDERSCORE_IDENT_RE="[a-zA-Z_]\\w*",e.NUMBER_RE="\\b\\d+(\\.\\d+)?",e.C_NUMBER_RE="(-?)(\\b0[xX][a-fA-F0-9]+|(\\b\\d+(\\.\\d*)?|\\.\\d+)([eE][-+]?\\d+)?)",e.BINARY_NUMBER_RE="\\b(0b[01]+)",e.RE_STARTERS_RE="!|!=|!==|%|%=|&|&&|&=|\\*|\\*=|\\+|\\+=|,|-|-=|/=|/|:|;|<<|<<=|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\\?|\\[|\\{|\\(|\\^|\\^=|\\||\\|=|\\|\\||~",e.BACKSLASH_ESCAPE={begin:"\\\\[\\s\\S]",relevance:0},e.APOS_STRING_MODE={className:"string",begin:"'",end:"'",illegal:"\\n",contains:[e.BACKSLASH_ESCAPE]},e.QUOTE_STRING_MODE={className:"string",begin:'"',end:'"',illegal:"\\n",contains:[e.BACKSLASH_ESCAPE]},e.PHRASAL_WORDS_MODE={begin:/\b(a|an|the|are|I|I'm|isn't|don't|doesn't|won't|but|just|should|pretty|simply|enough|gonna|going|wtf|so|such|will|you|your|like)\b/},e.COMMENT=function(n,t,r){var a=e.inherit({className:"comment",begin:n,end:t,contains:[]},r||{});return a.contains.push(e.PHRASAL_WORDS_MODE),a.contains.push({className:"doctag",begin:"(?:TODO|FIXME|NOTE|BUG|XXX):",relevance:0}),a},e.C_LINE_COMMENT_MODE=e.COMMENT("//","$"),e.C_BLOCK_COMMENT_MODE=e.COMMENT("/\\*","\\*/"),e.HASH_COMMENT_MODE=e.COMMENT("#","$"),e.NUMBER_MODE={className:"number",begin:e.NUMBER_RE,relevance:0},e.C_NUMBER_MODE={className:"number",begin:e.C_NUMBER_RE,relevance:0},e.BINARY_NUMBER_MODE={className:"number",begin:e.BINARY_NUMBER_RE,relevance:0},e.CSS_NUMBER_MODE={className:"number",begin:e.NUMBER_RE+"(%|em|ex|ch|rem|vw|vh|vmin|vmax|cm|mm|in|pt|pc|px|deg|grad|rad|turn|s|ms|Hz|kHz|dpi|dpcm|dppx)?",relevance:0},e.REGEXP_MODE={className:"regexp",begin:/\//,end:/\/[gimuy]*/,illegal:/\n/,contains:[e.BACKSLASH_ESCAPE,{begin:/\[/,end:/\]/,relevance:0,contains:[e.BACKSLASH_ESCAPE]}]},e.TITLE_MODE={className:"title",begin:e.IDENT_RE,relevance:0},e.UNDERSCORE_TITLE_MODE={className:"title",begin:e.UNDERSCORE_IDENT_RE,relevance:0},e.METHOD_GUARD={begin:"\\.\\s*"+e.UNDERSCORE_IDENT_RE,relevance:0},e});
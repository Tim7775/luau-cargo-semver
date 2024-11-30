"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[314],{2926:(e,n,o)=>{o.r(n),o.d(n,{assets:()=>c,contentTitle:()=>a,default:()=>d,frontMatter:()=>s,metadata:()=>i,toc:()=>m});const i=JSON.parse('{"id":"memoization","title":"Memoization","description":"To improve the performance of the Semver library,","source":"@site/docs/memoization.md","sourceDirName":".","slug":"/memoization","permalink":"/luau-cargo-semver/docs/memoization","draft":false,"unlisted":false,"editUrl":"https://github.com/Tim7775/luau-cargo-semver/edit/main/docs/memoization.md","tags":[],"version":"current","sidebarPosition":5,"frontMatter":{"sidebar_position":5},"sidebar":"defaultSidebar","previous":{"title":"Examples","permalink":"/luau-cargo-semver/docs/examples"}}');var r=o(4848),t=o(8453);const s={sidebar_position:5},a="Memoization",c={},m=[{value:"Example:",id:"example",level:3}];function u(e){const n={a:"a",blockquote:"blockquote",br:"br",code:"code",h1:"h1",h3:"h3",header:"header",p:"p",pre:"pre",strong:"strong",...(0,t.R)(),...e.components};return(0,r.jsxs)(r.Fragment,{children:[(0,r.jsx)(n.header,{children:(0,r.jsx)(n.h1,{id:"memoization",children:"Memoization"})}),"\n",(0,r.jsxs)(n.p,{children:["To improve the performance of the ",(0,r.jsx)(n.a,{href:"../api/Semver",children:"Semver"})," library,\nyou can register memoization functions using ",(0,r.jsx)(n.a,{href:"../api/Semver#setMemoizationFunc",children:"Semver.setMemoizationFunc"}),".\nMemoization functions registered with this function cache the results of ",(0,r.jsx)(n.a,{href:"../api/Version#parse",children:"Version.parse"}),"\nor ",(0,r.jsx)(n.a,{href:"../api/VersionReq#parse",children:"VersionReq.parse"}),", which can prevent repeated parsing of semver strings."]}),"\n",(0,r.jsxs)(n.blockquote,{children:["\n",(0,r.jsxs)(n.p,{children:[(0,r.jsxs)(n.strong,{children:["\ud83d\udca1"," Tip:"]}),(0,r.jsx)(n.br,{}),"\n","Memoization functions can be found in the ",(0,r.jsx)(n.a,{href:"https://github.com/tim7775/luau-caching-and-memoization",children:"luau-caching-and-memoization"})," repository."]}),"\n"]}),"\n",(0,r.jsx)(n.h3,{id:"example",children:"Example:"}),"\n",(0,r.jsx)(n.pre,{children:(0,r.jsx)(n.code,{className:"language-lua",children:'Semver.setMemoizationFunc("Version", memoizeFrame)\nSemver.setMemoizationFunc("VersionReq", function(parseFunc)\n\treturn memoizeRecentlyUsed(50, parseFunc)\nend)\n'})})]})}function d(e={}){const{wrapper:n}={...(0,t.R)(),...e.components};return n?(0,r.jsx)(n,{...e,children:(0,r.jsx)(u,{...e})}):u(e)}},8453:(e,n,o)=>{o.d(n,{R:()=>s,x:()=>a});var i=o(6540);const r={},t=i.createContext(r);function s(e){const n=i.useContext(t);return i.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function a(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(r):e.components||r:s(e.components),i.createElement(t.Provider,{value:n},e.children)}}}]);
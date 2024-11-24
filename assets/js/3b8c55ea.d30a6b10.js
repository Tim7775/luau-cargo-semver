"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[803],{7248:(e,n,l)=>{l.r(n),l.d(n,{assets:()=>i,contentTitle:()=>a,default:()=>h,frontMatter:()=>s,metadata:()=>o,toc:()=>c});const o=JSON.parse('{"id":"installation","title":"Installation","description":"Method 1 - Git Submodule","source":"@site/docs/installation.md","sourceDirName":".","slug":"/installation","permalink":"/luau-cargo-semver/docs/installation","draft":false,"unlisted":false,"editUrl":"https://github.com/Tim7775/luau-cargo-semver/edit/main/docs/installation.md","tags":[],"version":"current","sidebarPosition":2,"frontMatter":{"sidebar_position":2},"sidebar":"defaultSidebar","previous":{"title":"Getting Started with Semver","permalink":"/luau-cargo-semver/docs/intro"},"next":{"title":"Specification","permalink":"/luau-cargo-semver/docs/specification"}}');var t=l(4848),r=l(8453);const s={sidebar_position:2},a="Installation",i={},c=[{value:"Method 1 - Git Submodule",id:"method-1---git-submodule",level:3},{value:"Method 2 - Wally package (Roblox)",id:"method-2---wally-package-roblox",level:3},{value:"Method 3 - Manual (Roblox)",id:"method-3---manual-roblox",level:3},{value:"Method 4 - npm (roblox-ts)",id:"method-4---npm-roblox-ts",level:3}];function d(e){const n={a:"a",blockquote:"blockquote",br:"br",code:"code",em:"em",h1:"h1",h3:"h3",header:"header",li:"li",ol:"ol",p:"p",pre:"pre",strong:"strong",...(0,r.R)(),...e.components};return(0,t.jsxs)(t.Fragment,{children:[(0,t.jsx)(n.header,{children:(0,t.jsx)(n.h1,{id:"installation",children:"Installation"})}),"\n",(0,t.jsx)(n.h3,{id:"method-1---git-submodule",children:"Method 1 - Git Submodule"}),"\n",(0,t.jsxs)(n.p,{children:["Add the luau-cargo-semver repository as a git submodule (",(0,t.jsx)(n.a,{href:"https://gist.github.com/gitaarik/8735255",children:"Git Submodules explanation"}),"):"]}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-bash",children:"git submodule add https://github.com/Tim7775/luau-cargo-semver.git/ .lune/luau-cargo-semver\n"})}),"\n",(0,t.jsx)(n.p,{children:"Scripts in the .lune folder can now require Semver as follows:"}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-lua",children:'local Semver = require("./luau-cargo-semver/lib/Semver")\n'})}),"\n",(0,t.jsx)(n.h3,{id:"method-2---wally-package-roblox",children:"Method 2 - Wally package (Roblox)"}),"\n",(0,t.jsxs)(n.p,{children:["Add Semver to your ",(0,t.jsx)(n.code,{children:"wally.toml"})," dependency list:"]}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-toml",children:'[dependencies]\nSemver = "tim7775/semver@1"\n'})}),"\n",(0,t.jsxs)(n.p,{children:["Then run ",(0,t.jsx)(n.code,{children:"wally install"})," within your project."]}),"\n",(0,t.jsx)(n.p,{children:"Semver can now be required like any other module grabbed from Wally."}),"\n",(0,t.jsxs)(n.blockquote,{children:["\n",(0,t.jsxs)(n.p,{children:[(0,t.jsxs)(n.strong,{children:["\u2139\ufe0f"," Note:"]}),(0,t.jsx)(n.br,{}),"\n","Not familiar with Wally? Wally is a package manager (like npm) for the Roblox ecosystem.\nTo get started, check out the ",(0,t.jsx)(n.a,{href:"https://github.com/UpliftGames/wally",children:"Wally repository"}),"."]}),"\n"]}),"\n",(0,t.jsx)(n.h3,{id:"method-3---manual-roblox",children:"Method 3 - Manual (Roblox)"}),"\n",(0,t.jsxs)(n.ol,{children:["\n",(0,t.jsxs)(n.li,{children:["Visit the ",(0,t.jsx)(n.a,{href:"https://github.com/Tim7775/luau-cargo-semver/releases/latest",children:"latest release"})]}),"\n",(0,t.jsxs)(n.li,{children:["Under ",(0,t.jsx)(n.em,{children:"Assets"}),", click ",(0,t.jsx)(n.code,{children:"luau-cargo-semver.rbxm"})]}),"\n",(0,t.jsx)(n.li,{children:"Open Roblox Studio and drag the file into the explorer"}),"\n"]}),"\n",(0,t.jsx)(n.h3,{id:"method-4---npm-roblox-ts",children:"Method 4 - npm (roblox-ts)"}),"\n",(0,t.jsx)(n.p,{children:"Run the following command to install the cargo-semver roblox-ts package:"}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-bash",children:"npm install @rbxts/cargo-semver\n"})}),"\n",(0,t.jsx)(n.p,{children:"Semver can now be imported and used as follows:"}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-typescript",children:'import Semver from "@rbxts/cargo-semver"\nconst [ok, message] = Semver.validateVersion("1.0.0")\n'})})]})}function h(e={}){const{wrapper:n}={...(0,r.R)(),...e.components};return n?(0,t.jsx)(n,{...e,children:(0,t.jsx)(d,{...e})}):d(e)}},8453:(e,n,l)=>{l.d(n,{R:()=>s,x:()=>a});var o=l(6540);const t={},r=o.createContext(t);function s(e){const n=o.useContext(r);return o.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function a(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(t):e.components||t:s(e.components),o.createElement(r.Provider,{value:n},e.children)}}}]);
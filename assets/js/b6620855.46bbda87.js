"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[229],{5378:(e,t,i)=>{i.r(t),i.d(t,{assets:()=>c,contentTitle:()=>a,default:()=>d,frontMatter:()=>n,metadata:()=>s,toc:()=>l});const s=JSON.parse('{"id":"specification","title":"Specification","description":"The goal of this library is to replicate the exact behavior of the Rust crate semver (currently v1.0.20) used by Cargo (and Wally, Foreman and Rokit). It succeeds in this with only minor deviations that should only ever present themselves when dealing with hostile user input.","source":"@site/docs/specification.md","sourceDirName":".","slug":"/specification","permalink":"/luau-cargo-semver/docs/specification","draft":false,"unlisted":false,"editUrl":"https://github.com/Tim7775/luau-cargo-semver/edit/main/docs/specification.md","tags":[],"version":"current","sidebarPosition":3,"frontMatter":{"sidebar_position":3},"sidebar":"defaultSidebar","previous":{"title":"Installation","permalink":"/luau-cargo-semver/docs/installation"},"next":{"title":"Examples","permalink":"/luau-cargo-semver/docs/examples"}}');var r=i(4848),o=i(8453);const n={sidebar_position:3},a="Specification",c={},l=[{value:"Deviations from Cargo&#39;s semver:",id:"deviations-from-cargos-semver",level:4}];function h(e){const t={a:"a",code:"code",h1:"h1",h4:"h4",header:"header",li:"li",ol:"ol",p:"p",...(0,o.R)(),...e.components};return(0,r.jsxs)(r.Fragment,{children:[(0,r.jsx)(t.header,{children:(0,r.jsx)(t.h1,{id:"specification",children:"Specification"})}),"\n",(0,r.jsxs)(t.p,{children:["The goal of this library is to replicate the exact behavior of the Rust crate ",(0,r.jsx)(t.a,{href:"https://crates.io/crates/semver",children:(0,r.jsx)(t.code,{children:"semver"})})," (currently ",(0,r.jsx)(t.code,{children:"v1.0.20"}),") used by ",(0,r.jsx)(t.a,{href:"https://github.com/rust-lang/cargo",children:"Cargo"})," (and ",(0,r.jsx)(t.a,{href:"https://github.com/UpliftGames/wally",children:"Wally"}),", ",(0,r.jsx)(t.a,{href:"https://github.com/Roblox/foreman",children:"Foreman"})," and ",(0,r.jsx)(t.a,{href:"https://github.com/rojo-rbx/rokit",children:"Rokit"}),"). It succeeds in this with only minor deviations that should only ever present themselves when dealing with hostile user input."]}),"\n",(0,r.jsx)(t.h4,{id:"deviations-from-cargos-semver",children:"Deviations from Cargo's semver:"}),"\n",(0,r.jsxs)(t.ol,{children:["\n",(0,r.jsxs)(t.li,{children:["Identifiers (",(0,r.jsx)(t.a,{href:"../api/Prerelease",children:"Prerelease"})," and ",(0,r.jsx)(t.a,{href:"../api/BuildMetadata",children:"BuildMetadata"}),") have a maximum length of 512 characters (Note: This should be more than enough for all use cases. For context, npm has a limit of 256 characters for the complete semver string)."]}),"\n",(0,r.jsx)(t.li,{children:"Major, minor and patch version numbers overflow at LUAU_MAX_PRECISE_INT (2^53 - 1) instead of u64::MAX (2^63 - 1) (Note: Numbers in identifiers do not have this limitation, they get compared with arbitrary-precision)."}),"\n"]})]})}function d(e={}){const{wrapper:t}={...(0,o.R)(),...e.components};return t?(0,r.jsx)(t,{...e,children:(0,r.jsx)(h,{...e})}):h(e)}},8453:(e,t,i)=>{i.d(t,{R:()=>n,x:()=>a});var s=i(6540);const r={},o=s.createContext(r);function n(e){const t=s.useContext(o);return s.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function a(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(r):e.components||r:n(e.components),s.createElement(o.Provider,{value:t},e.children)}}}]);
"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[273],{3905:(e,t,r)=>{r.d(t,{Zo:()=>s,kt:()=>d});var n=r(67294);function o(e,t,r){return t in e?Object.defineProperty(e,t,{value:r,enumerable:!0,configurable:!0,writable:!0}):e[t]=r,e}function a(e,t){var r=Object.keys(e);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(e);t&&(n=n.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),r.push.apply(r,n)}return r}function i(e){for(var t=1;t<arguments.length;t++){var r=null!=arguments[t]?arguments[t]:{};t%2?a(Object(r),!0).forEach((function(t){o(e,t,r[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(r)):a(Object(r)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(r,t))}))}return e}function c(e,t){if(null==e)return{};var r,n,o=function(e,t){if(null==e)return{};var r,n,o={},a=Object.keys(e);for(n=0;n<a.length;n++)r=a[n],t.indexOf(r)>=0||(o[r]=e[r]);return o}(e,t);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);for(n=0;n<a.length;n++)r=a[n],t.indexOf(r)>=0||Object.prototype.propertyIsEnumerable.call(e,r)&&(o[r]=e[r])}return o}var p=n.createContext({}),m=function(e){var t=n.useContext(p),r=t;return e&&(r="function"==typeof e?e(t):i(i({},t),e)),r},s=function(e){var t=m(e.components);return n.createElement(p.Provider,{value:t},e.children)},u="mdxType",l={inlineCode:"code",wrapper:function(e){var t=e.children;return n.createElement(n.Fragment,{},t)}},f=n.forwardRef((function(e,t){var r=e.components,o=e.mdxType,a=e.originalType,p=e.parentName,s=c(e,["components","mdxType","originalType","parentName"]),u=m(r),f=o,d=u["".concat(p,".").concat(f)]||u[f]||l[f]||a;return r?n.createElement(d,i(i({ref:t},s),{},{components:r})):n.createElement(d,i({ref:t},s))}));function d(e,t){var r=arguments,o=t&&t.mdxType;if("string"==typeof e||o){var a=r.length,i=new Array(a);i[0]=f;var c={};for(var p in t)hasOwnProperty.call(t,p)&&(c[p]=t[p]);c.originalType=e,c[u]="string"==typeof e?e:o,i[1]=c;for(var m=2;m<a;m++)i[m]=r[m];return n.createElement.apply(null,i)}return n.createElement.apply(null,r)}f.displayName="MDXCreateElement"},35807:(e,t,r)=>{r.r(t),r.d(t,{assets:()=>p,contentTitle:()=>i,default:()=>l,frontMatter:()=>a,metadata:()=>c,toc:()=>m});var n=r(87462),o=(r(67294),r(3905));const a={sidebar_position:5},i="Memoization",c={unversionedId:"memoization",id:"memoization",title:"Memoization",description:"To improve the performance of the Semver library,",source:"@site/docs/memoization.md",sourceDirName:".",slug:"/memoization",permalink:"/luau-cargo-semver/docs/memoization",draft:!1,editUrl:"https://github.com/Tim7775/luau-cargo-semver/edit/main/docs/memoization.md",tags:[],version:"current",sidebarPosition:5,frontMatter:{sidebar_position:5},sidebar:"defaultSidebar",previous:{title:"Examples",permalink:"/luau-cargo-semver/docs/examples"}},p={},m=[{value:"Example:",id:"example",level:3}],s={toc:m},u="wrapper";function l(e){let{components:t,...r}=e;return(0,o.kt)(u,(0,n.Z)({},s,r,{components:t,mdxType:"MDXLayout"}),(0,o.kt)("h1",{id:"memoization"},"Memoization"),(0,o.kt)("p",null,"To improve the performance of the ",(0,o.kt)("a",{parentName:"p",href:"../api/Semver"},"Semver")," library,\nyou can register memoization functions using ",(0,o.kt)("a",{parentName:"p",href:"../api/Semver#setMemoizationFunc"},"Semver.setMemoizationFunc"),".\nMemoization functions registered with this function cache the results of ",(0,o.kt)("a",{parentName:"p",href:"../api/Version#parse"},"Version.parse"),"\nor ",(0,o.kt)("a",{parentName:"p",href:"../api/VersionReq#parse"},"VersionReq.parse"),", which can prevent repeated parsing of semver strings."),(0,o.kt)("blockquote",null,(0,o.kt)("p",{parentName:"blockquote"},(0,o.kt)("strong",{parentName:"p"},"\ud83d\udca1 Tip:"),(0,o.kt)("br",{parentName:"p"}),"\n","Memoization functions can be found in the ",(0,o.kt)("a",{parentName:"p",href:"https://github.com/tim7775/luau-caching-and-memoization"},"luau-caching-and-memoization")," repository.")),(0,o.kt)("h3",{id:"example"},"Example:"),(0,o.kt)("pre",null,(0,o.kt)("code",{parentName:"pre",className:"language-lua"},'Semver.setMemoizationFunc("Version", memoizeFrame)\nSemver.setMemoizationFunc("VersionReq", function(parseFunc)\n    return memoizeRecentlyUsed(50, parseFunc)\nend)\n')))}l.isMDXComponent=!0}}]);
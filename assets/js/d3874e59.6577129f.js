"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[374],{52897:(e,t,n)=>{n.r(t),n.d(t,{HomepageFeatures:()=>d,default:()=>E});var a=n(87462),r=n(39960),l=n(52263),s=n(34510),c=n(86010),i=n(67294);const m={heroBanner:"heroBanner_e1Bh",buttons:"buttons_VwD3",features:"features_WS6B",featureSvg:"featureSvg_tqLR",titleOnBannerImage:"titleOnBannerImage_r7kd",taglineOnBannerImage:"taglineOnBannerImage_dLPr"},o=[{title:"Simple",description:"Provides a simple and idiomatic Luau API wrapper for the low-level Rust-style API."},{title:"Robust",description:"Passes every test included in the original Rust crate."},{title:"Performant",description:"Achieves great performance by parsing and evaluating semantic versions without creating unnecessary substrings."}];function u(e){let{image:t,title:n,description:a}=e;return i.createElement("div",{className:(0,c.Z)("col col--4")},t&&i.createElement("div",{className:"text--center"},i.createElement("img",{className:m.featureSvg,alt:n,src:t})),i.createElement("div",{className:"text--center padding-horiz--md"},i.createElement("h3",null,n),i.createElement("p",null,a)))}function d(){return o?i.createElement("section",{className:m.features},i.createElement("div",{className:"container"},i.createElement("div",{className:"row"},o.map(((e,t)=>i.createElement(u,(0,a.Z)({key:t},e))))))):null}function g(){const{siteConfig:e}=(0,l.Z)(),t=e.customFields.bannerImage,n=!!t,a=n?{backgroundImage:`url("${t}")`}:null,s=(0,c.Z)("hero__title",{[m.titleOnBannerImage]:n}),o=(0,c.Z)("hero__subtitle",{[m.taglineOnBannerImage]:n});return i.createElement("header",{className:(0,c.Z)("hero",m.heroBanner),style:a},i.createElement("div",{className:"container"},i.createElement("h1",{className:s},e.title),i.createElement("p",{className:o},e.tagline),i.createElement("div",{className:m.buttons},i.createElement(r.Z,{className:"button button--secondary button--lg",to:"/docs/intro"},"Get Started \u2192"))))}function E(){const{siteConfig:e,tagline:t}=(0,l.Z)();return i.createElement(s.Z,{title:e.title,description:t},i.createElement(g,null),i.createElement("main",null,i.createElement(d,null),i.createElement("div",{className:"container"})))}}}]);
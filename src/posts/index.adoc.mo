= Paulo Jerônimo's blog posts
:basedir: ..
:stylesdir: {basedir}/css
:linkcss:
:icons: font
:imagesdir: {basedir}/images
:nofooter:
:docinfodir: {basedir}
:docinfo: shared
include::{basedir}/uris-and-attributes.adoc[]
:og-description: Posts index page
:pt-br-post: pt-br
:english-post: en

include::{basedir}/icons.adoc[]

Hi! Many of my blog posts are written in Portuguese in a non technical
language and for Brazilians ({pt-br}).
Some of them are in English ({en}) and high technical to normal people
(non programmers).

{{#foreach-post}}
.*{{__post__.title}}*
****
[.text-center]
{pt-br-post}, {{__post__.date}}

image:posts/{{__post__.id}}/capa.mini.png[role="related left"]
{{__post__.abstract}}

*link:/posts/{{__post__.id}}/[Leia mais]*
****

{{/foreach-post}}

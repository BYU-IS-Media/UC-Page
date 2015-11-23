<cfset debugVar = false />
<cffile action="read" file="#ExpandPath( "./" )#index.html" variable="indexhtml">
<cftry>
	<cfset indexdata = XmlParse(indexhtml) />
	<cfcatch >
		<cfoutput>
			<h2>Parsing templated HTML failed.</h2>
			#Len(indexhtml)#
			<p>#cfcatch.message#</p>
			<p>Caught an exception, type = #CFCATCH.TYPE#</p>
			<p>The contents of the tag stack are:</p>
		</cfoutput>
		<cfdump var="#cfcatch.tagcontext#">
		<cfabort />
	</cfcatch>
</cftry>
<cfscript>
	htmlhead_children = XmlSearch(indexdata, "/html/head");
	htmlhead = "";
	for (i = 1; i LTE ArrayLen(htmlhead_children); i = i + 1)
		htmlhead &= ReReplace(ReReplace(ToString(htmlhead_children[i]) & Chr(13) & Chr(10),"^<\?(.+)\?>",""),"<\/?head>","","all");

	if(debugVar) WriteOutput("Pre-replace length: "&Len(htmlhead)&"<br />");
	quotes = "["&Chr(34)&Chr(39)&"]";
	regexp_metarefresh = "<meta[^>]* http-equiv=#quotes#refresh#quotes#[^>]*/>";
	htmlhead = ReReplace(htmlhead,regexp_metarefresh,"");
	if(debugVar) WriteOutput("Post-replace length: "&Len(htmlhead)&"<br />");
	if(debugVar) WriteOutput(htmlhead);

 	htmlbody_children = XmlSearch(indexdata, "/html/body/div/div");
	htmlbody = "";
 	for (i = 1; i LTE ArrayLen(htmlbody_children); i = i + 1)
		htmlbody &= ReReplace(ToString(htmlbody_children[i]) & Chr(13) & Chr(10),"^<\?(.+)\?>","");
	/*
	strings_to_replace = {
		'FULL_NAME':CASData.fullName,
		'EMAIL_ADDRESS':CASData.emailAddress,
		'PHONE_NUMBER':CASData.personId,
		'EMAIL_TOKEN':LEFT(Session.EmailToken, 6)
	};
	for (text_replace in strings_to_replace) {
		htmlbody = ReReplace(htmlbody,"%%"&text_replace&"%%",strings_to_replace[text_replace],"all");
	}
	*/
	htmlbody = ReReplace(htmlbody,"[pP][hH][oO][nN][eE].?\s?[\d\r\n\s]+<br/?>","","all");

</cfscript>
<!---
HTML Head:
<cfdump var="#htmlhead#" label="HTML Head (read from file)" format="text" />
CAS:
<cfdump var="#CASData#" label="CAS Person Data" format="text" />
--->
<!---
<cfif CGI.SERVER_PORT NEQ "443" AND CGI.SERVER_PORT NEQ "8080">
	<cflocation url="https://#cgi.server_name##cgi.script_name#?#cgi.query_string#" addtoken="no">
</cfif>
--->
<cfset additionalHeaderData = '#htmlhead#' />
<cfinclude template="/site/template/header.cfm">

<div id="content" class="wrapper">
	<!---<cfinclude template="/site/intranet/intranet.cfm">--->
	<cfoutput>
		#htmlbody#
	</cfoutput>
</div>
<cfinclude template="/site/template/footer.cfm">
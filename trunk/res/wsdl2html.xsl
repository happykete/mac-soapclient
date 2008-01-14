<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
	version="1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
	xmlns:http="http://schemas.xmlsoap.org/wsdl/http/" 
	xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" 
	xmlns:mime="http://schemas.xmlsoap.org/wsdl/mime/" 
	xmlns:tm="http://microsoft.com/wsdl/mime/textMatching/" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" 
	xmlns:exsl="http://exslt.org/common"
	xmlns:regexp="http://exslt.org/regular-expressions"
	xmlns:math="http://exslt.org/math"
	extension-element-prefixes="exsl regexp math"
	exclude-result-prefixes="wsdl http soap mime tm xs soapenc"
>

<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

<xsl:template match="wsdl:definitions">
<html>
	<head>
    	<link type="text/css" rel="stylesheet" href="file://%@"/>
		<script type="text/javascript" src="file://%@"></script>
	</head>
	<body onload="bodyLoaded(event);">
		<xsl:apply-templates select="wsdl:service"/>
	</body>
</html>
</xsl:template>

<xsl:template match="wsdl:service">
	<table border="0">
		<tr id="serviceRow">
			<th>Service:</th>
			<td><strong><xsl:value-of select="@name"/></strong></td>
		</tr>
		<tr>
			<xsl:apply-templates select="wsdl:port" mode="toc"/>
		</tr>
	</table>
	<form onsubmit="formSubmitted(event);">
		<xsl:apply-templates select="wsdl:port" mode="form"/>
	</form>
</xsl:template>


<xsl:template match="wsdl:port" mode="toc">
	<xsl:variable name="portBinding" select="regexp:replace(@binding, '(^[^:]+:)', '')"/>
	
	<xsl:for-each select="/wsdl:definitions/wsdl:binding[@name=$portBinding]">
		<xsl:variable name="bindingTransport" select="soap:binding/@transport"/>
		<xsl:variable name="bindingType" select="regexp:replace(@type, '(^[^:]+:)', '')"/>
		<xsl:if test="$bindingTransport='http://schemas.xmlsoap.org/soap/http'">
			<th><label for="methodSelect">Method:</label></th>
			<td>
				<select id="methodSelect" onchange="methodPopupChanged(event);">
					<xsl:for-each select="wsdl:operation">
						<xsl:variable name="operationName" select="@name"/>
						<xsl:variable name="arg0Name" select="wsdl:input/@name"/>
						<xsl:variable name="operationId" select="concat(@name, '-', $arg0Name)"/>
						<xsl:message>
							operationId: <xsl:value-of select="$operationId"/>
						</xsl:message>
						<xsl:variable name="soapAction" select="soap:operation/@soapAction"/>
						<xsl:variable name="operationStyle" select="soap:operation/@style"/>

						<xsl:choose>
							<xsl:when test="$arg0Name">
								<xsl:for-each select="/wsdl:definitions/wsdl:portType[@name=$bindingType]/wsdl:operation[@name=$operationName and wsdl:input[1]/@name=$arg0Name]">
									<option value="{$operationId}"><xsl:value-of select="$operationName"/></option>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="/wsdl:definitions/wsdl:portType[@name=$bindingType]/wsdl:operation[@name=$operationName]">
									<option value="{$operationId}"><xsl:value-of select="$operationName"/></option>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					
					</xsl:for-each>
				</select>
			</td>
		</xsl:if>

	</xsl:for-each>
</xsl:template>


<xsl:template match="wsdl:port" mode="form">
	<xsl:variable name="portEndpoint" select="soap:address/@location"/>
	<xsl:variable name="portBinding" select="regexp:replace(@binding, '(^[^:]+:)', '')"/>
	
	<xsl:for-each select="/wsdl:definitions/wsdl:binding[@name=$portBinding]">
		<xsl:variable name="bindingTransport" select="soap:binding/@transport"/>
		<xsl:variable name="bindingType" select="regexp:replace(@type, '(^[^:]+:)', '')"/>
		<xsl:if test="$bindingTransport='http://schemas.xmlsoap.org/soap/http'">
			
			<div id="settingsWrap">
				<xsl:for-each select="wsdl:operation">
					<xsl:variable name="operationName" select="@name"/>
					<xsl:variable name="arg0Name" select="wsdl:input/@name"/>
					<xsl:variable name="operationId" select="concat(@name, '-', $arg0Name)"/>
					<xsl:variable name="soapAction" select="soap:operation/@soapAction"/>

					<xsl:variable name="bindingStyle">
						<xsl:choose>
							<xsl:when test="soap:operation/@style">
								<xsl:value-of select="soap:operation/@style"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="../soap:binding/@style"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<xsl:variable name="styleAttrVal">
						<xsl:choose>
							<xsl:when test="position()=1">display:block;</xsl:when>
							<xsl:otherwise>display:none;</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					
					<xsl:for-each select="/wsdl:definitions/wsdl:portType[@name=$bindingType]/wsdl:operation[@name=$operationName and string(wsdl:input/@name)=string($arg0Name)]">
						<table id="{$operationId}-wrap" class="operationTable" style="{$styleAttrVal}">
							<tr>
								<th><label for="{$operationId}-endpointUri">EndpointURI:</label></th>
								<td><input id="{$operationId}-endpointUri" type="text" value="{$portEndpoint}" onkeypress="inputElementChanged(event);"/></td>
							</tr>
							<tr>
								<th><label for="{$operationId}-bindingStyle">Binding Style:</label></th>
								<td><input id="{$operationId}-bindingStyle" type="text" value="{$bindingStyle}" onkeypress="inputElementChanged(event);"/></td>
							</tr>
							<tr>
								<th><label for="{$operationId}-soapAction">SOAPAction:</label></th>
								<td><input id="{$operationId}-soapAction" type="text" value="{$soapAction}" onkeypress="inputElementChanged(event);"/></td>
							</tr>
							<tr>
								<th><label for="{$operationId}-namespace">Namespace:</label></th>
								<td><input id="{$operationId}-namespace" type="text" value="{/wsdl:definitions/@targetNamespace}" onkeypress="inputElementChanged(event);"/></td>
							</tr>
							
							<xsl:variable name="inputName" select="regexp:replace(wsdl:input/@message, '(^[^:]+:)', '')"/>
							<xsl:for-each select="/wsdl:definitions/wsdl:message[regexp:replace(@name, '(^[^:]+:)', '')=$inputName]">
								<xsl:variable name="paramContent">
									<xsl:call-template name="paramContent">
										<xsl:with-param name="parts" select="wsdl:part"/>
										<xsl:with-param name="operationName" select="$operationName"/>
										<xsl:with-param name="operationId" select="$operationId"/>
									</xsl:call-template>
								</xsl:variable>
								
								<!-- if there is a table with rows -->
								<xsl:if test="exsl:node-set($paramContent)/*/*">
									<tr>
										<th>Parameters:</th>
										<td id="{$operationId}-params-wrap">
											<xsl:copy-of select="$paramContent"/>
										</td>
									</tr>
								</xsl:if>
							</xsl:for-each>
					
						</table>									
					</xsl:for-each>
	
				</xsl:for-each>
			</div>
		</xsl:if>
	</xsl:for-each>
</xsl:template>


<xsl:template name="paramContent">
	<xsl:param name="operationName"/>
	<xsl:param name="operationId"/>
	<xsl:param name="parts"/>

	<xsl:variable name="schemaLocation" select="/wsdl:definitions/wsdl:types/xs:schema/xs:import/@schemaLocation"/>

	<xsl:variable name="schema">
		<xsl:choose>
			<xsl:when test="$schemaLocation">
				<xsl:for-each select="/wsdl:definitions/wsdl:types/xs:schema">
					<xsl:copy>
						<xsl:copy-of select="@*|namespace::*"/>
						<xsl:copy-of select="document($schemaLocation)//xs:schema/node()"/>
						<xsl:copy-of select="node()"/>
					</xsl:copy>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="/wsdl:definitions/wsdl:types/xs:schema"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<table border="0" id="paramTable">
		<xsl:for-each select="$parts">
			<xsl:variable name="typeAttr" select="regexp:replace(@type, '(^[^:]+:)', '')"/>
			<xsl:variable name="complexType" select="exsl:node-set($schema)/*//xs:complexType[@name=$typeAttr]"/>

			<xsl:choose>

<!-- do complex type referenced by type attribute -->
				<xsl:when test="$typeAttr and $complexType">
					<xsl:call-template name="doCustomComplexType">
						<xsl:with-param name="operationName" select="$operationName"/>
						<xsl:with-param name="operationId" select="$operationId"/>
						<xsl:with-param name="typeAttr" select="$typeAttr"/>
						<xsl:with-param name="complexType" select="$complexType"/>
					</xsl:call-template>				
				</xsl:when>

<!-- do complex type referenced by element attribute -->
				<xsl:when test="@element">
					<xsl:variable name="parametersName" select="regexp:replace(@element, '(^[^:]+:)', '')"/>
					<xsl:for-each select="exsl:node-set($schema)//xs:element[@name=$parametersName]">
						
						<xsl:variable name="hasAnonComplexType" select="boolean(xs:complexType)"/>
						<xsl:variable name="type" select="regexp:replace(@type, '(^[^:]+:)', '')"/>
						<xsl:variable name="elements">
							<xsl:choose>
								<xsl:when test="$hasAnonComplexType">
									<xsl:copy-of select=".//xs:element"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:copy-of select="exsl:node-set($schema)//xs:complexType[@name=$type]//xs:element"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						
						<xsl:for-each select="exsl:node-set($elements)/*">
							<xsl:call-template name="doTextField">
								<xsl:with-param name="name" select="@name"/>
								<xsl:with-param name="operationName" select="$operationName"/>
								<xsl:with-param name="operationId" select="$operationId"/>
								<xsl:with-param name="type" select="@type"/>
							</xsl:call-template>
						</xsl:for-each>
					
					</xsl:for-each>
				</xsl:when>

<!-- do simple type -->
				<xsl:otherwise>
					<xsl:variable name="typePrefix" select="substring-before(@type, ':')"/>
					<xsl:call-template name="doTextField">
						<xsl:with-param name="name" select="@name"/>
						<xsl:with-param name="operationName" select="$operationName"/>
						<xsl:with-param name="operationId" select="$operationId"/>
						<xsl:with-param name="type" select="@type"/>
						<xsl:with-param name="typeUri" select="namespace::*[name()=$typePrefix]"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</table>
</xsl:template>


<xsl:template name="doCustomComplexType">
	<xsl:param name="operationName"/>
	<xsl:param name="operationId"/>
	<xsl:param name="typeAttr"/>
	<xsl:param name="complexType"/>
	<xsl:param name="qualifiedObjName"/>
	<xsl:variable name="localName" select="@name"/>
	<xsl:variable name="typePrefix" select="substring-before(@type, ':')"/>
	<xsl:variable name="typeUri" select="namespace::*[name()=$typePrefix]"/>
	
	<xsl:for-each select="$complexType">
		<xsl:variable name="uid" select="concat($typeAttr, '-', math:random())"/>
		<xsl:for-each select=".//xs:element">
			
			<xsl:variable name="subLocalName" select="@name"/>
			<xsl:variable name="subTypePrefix" select="substring-before(@type, ':')"/>
			<xsl:variable name="subTypeLocalName" select="substring-after(@type, ':')"/>
			<xsl:variable name="subTypeUri" select="namespace::*[name()=$subTypePrefix]"/>
			
			<xsl:choose>
				<xsl:when test="$subTypeUri = $typeUri">
					<!-- do nested complex type -->

					<xsl:call-template name="doCustomComplexType">
						<xsl:with-param name="operationName" select="$operationName"/>
						<xsl:with-param name="operationId" select="$operationId"/>
						<xsl:with-param name="typeAttr" select="regexp:replace(@type, '(^[^:]+:)', '')"/>
						<xsl:with-param name="complexType" select="//xs:complexType[@name=$subTypeLocalName]"/>
						<xsl:with-param name="qualifiedObjName" select="concat($complexType/@name, '.')"/>
					</xsl:call-template>				

				</xsl:when>
				<xsl:otherwise>
					<!-- do nested simple type -->

					<xsl:variable name="objName">
						<xsl:choose>
							<xsl:when test="$complexType/@name">
								<xsl:value-of select="concat($qualifiedObjName ,$complexType/@name, '.')"/>
							</xsl:when>
							<xsl:otherwise></xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
		
					<xsl:call-template name="doTextField">
						<xsl:with-param name="uid" select="$uid"/>
						<xsl:with-param name="localName" select="$localName"/>
						<xsl:with-param name="typePrefix" select="$typePrefix"/>
						<xsl:with-param name="typeUri" select="$typeUri"/>
						<xsl:with-param name="name" select="concat($objName, @name)"/>
						<xsl:with-param name="operationName" select="$operationName"/>
						<xsl:with-param name="operationId" select="$operationId"/>
						<xsl:with-param name="type" select="@type"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>

		</xsl:for-each>
	</xsl:for-each>
</xsl:template>


<xsl:template name="doTextField">
	<xsl:param name="uid"/>
	<xsl:param name="localName"/>
	<xsl:param name="typePrefix"/>
	<xsl:param name="typeUri"/>
	<xsl:param name="name"/>
	<xsl:param name="operationName"/>
	<xsl:param name="operationId"/>
	<xsl:param name="type"/>
	<tr>
		<th><label><xsl:value-of select="$name"/>:</label></th>
		<td>
			<input id="{concat($operationId,'-',$name)}" onkeypress="inputElementChanged(event);"
				   type="text" name="{$name}" placeholder="{$type}" 
				   uid="{$uid}" typePrefix="{$typePrefix}" typeUri="{$typeUri}" localName="{$localName}"/>
		</td>
	</tr>	
</xsl:template>


</xsl:stylesheet>


<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="clMax" value="0"/>
<c:forEach items="${chartData}" var="clItem">
    <c:if test="${clItem[1] > clMax}"><c:set var="clMax" value="${clItem[1]}"/></c:if>
</c:forEach>
<c:if test="${clMax <= 0}"><c:set var="clMax" value="1"/></c:if>
<c:set var="clN" value="${fn:length(chartData)}"/>
<c:set var="clDx" value="${clN > 1 ? 420 div (clN - 1) : 420}"/>
<c:set var="clLine" value=""/>
<c:set var="clArea" value=""/>
<c:forEach items="${chartData}" var="clItem" varStatus="clSt">
    <c:set var="clX" value="${40 + clSt.index * clDx}"/>
    <c:set var="clY" value="${150 - (clItem[1] * 115.0) div clMax}"/>
    <c:set var="clPt" value="${clX},${clY}"/>
    <c:choose>
        <c:when test="${clSt.first}">
            <c:set var="clLine" value="M ${clPt}"/>
            <c:set var="clArea" value="M ${clPt}"/>
        </c:when>
        <c:otherwise>
            <c:set var="clLine" value="${clLine} L ${clPt}"/>
            <c:set var="clArea" value="${clArea} L ${clPt}"/>
        </c:otherwise>
    </c:choose>
</c:forEach>
<c:set var="clArea" value="${clArea} L 460,150 L 40,150 Z"/>
<svg class="chart-svg" viewBox="0 0 500 190" role="img" aria-label="${chartTitle}">
    <line x1="40" y1="30" x2="460" y2="30" class="chart-grid-line" stroke-dasharray="4 4"/>
    <line x1="40" y1="70" x2="460" y2="70" class="chart-grid-line" stroke-dasharray="4 4"/>
    <line x1="40" y1="110" x2="460" y2="110" class="chart-grid-line" stroke-dasharray="4 4"/>
    <line x1="40" y1="150" x2="460" y2="150" class="chart-grid-line"/>
    <path class="line-area" d="${clArea}"/>
    <path class="line-path" d="${clLine}"/>
    <c:forEach items="${chartData}" var="clItem" varStatus="clSt">
        <c:set var="clX" value="${40 + clSt.index * clDx}"/>
        <c:set var="clY" value="${150 - (clItem[1] * 115.0) div clMax}"/>
        <c:if test="${clN <= 12}">
            <circle class="line-dot" cx="${clX}" cy="${clY}" r="4"/>
            <text class="line-value" x="${clX}" y="${clY - 10}">${clItem[1]}</text>
        </c:if>
        <c:if test="${clN <= 12 || clSt.first || clSt.last || clSt.count mod 6 == 0}">
            <text class="line-label" x="${clX}" y="168">${clItem[0]}</text>
        </c:if>
    </c:forEach>
</svg>
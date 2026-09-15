<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<c:set var="cbMax" value="0"/>
<c:forEach items="${chartData}" var="cbItem">
    <c:if test="${cbItem[1] > cbMax}"><c:set var="cbMax" value="${cbItem[1]}"/></c:if>
</c:forEach>
<c:if test="${cbMax <= 0}"><c:set var="cbMax" value="1"/></c:if>
<c:set var="cbN" value="${fn:length(chartData)}"/>
<c:choose>
    <c:when test="${cbN == 5}"><c:set var="cbW" value="70"/><c:set var="cbDx" value="86"/></c:when>
    <c:when test="${cbN == 6}"><c:set var="cbW" value="60"/><c:set var="cbDx" value="72"/></c:when>
    <c:otherwise><c:set var="cbDx" value="${420 div cbN}"/><c:set var="cbW" value="${cbDx - 12 < 24 ? 24 : cbDx - 12}"/></c:otherwise>
</c:choose>
<svg class="chart-svg" viewBox="0 0 500 190" role="img" aria-label="${chartTitle}">
    <line x1="40" y1="30" x2="460" y2="30" class="chart-grid-line" stroke-dasharray="4 4"/>
    <line x1="40" y1="70" x2="460" y2="70" class="chart-grid-line" stroke-dasharray="4 4"/>
    <line x1="40" y1="110" x2="460" y2="110" class="chart-grid-line" stroke-dasharray="4 4"/>
    <line x1="40" y1="150" x2="460" y2="150" class="chart-grid-line"/>
    <c:forEach items="${chartData}" var="cbItem" varStatus="cbSt">
        <c:set var="cbH" value="${cbItem[1] > 0 ? (cbItem[1] * 130.0) div cbMax : 0}"/>
        <c:set var="cbX" value="${40 + cbSt.index * cbDx}"/>
        <c:set var="cbY" value="${150 - cbH}"/>
        <c:choose>
            <c:when test="${cbItem[1] > 0}"><c:set var="cbClass" value="${empty chartAlt && cbSt.count mod 2 == 0 ? 'bar-rect alt' : 'bar-rect'}"/></c:when>
            <c:otherwise><c:set var="cbClass" value="bar-rect"/></c:otherwise>
        </c:choose>
        <rect class="${cbClass}" x="${cbX}" y="${cbY}" width="${cbW}" height="${cbH}" rx="4"/>
        <c:if test="${cbItem[1] > 0}">
            <text class="bar-value" x="${cbX + cbW div 2}" y="${cbY - 6}">${cbItem[1]}</text>
        </c:if>
        <text class="bar-label" x="${cbX + cbW div 2}" y="168">${cbItem[0]}</text>
    </c:forEach>
</svg>
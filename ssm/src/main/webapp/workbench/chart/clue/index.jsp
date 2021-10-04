<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" +
            request.getServerPort() + request.getContextPath() + "/";
%>
<html lang="en">
<head>
    <base href="<%=basePath%>" />
    <title >统计图表</title>
</head>
<body>
    <img src="image/2.jpeg" style="height: 650px; width :1220px" alt="">
</body>
</html>
<%@ page contentType="text/html;charset=UTF-8" %>

<%
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" +
			request.getServerPort() + request.getContextPath() + "/";
%>

<html lang="en">
<head>
	<base href="<%=basePath%>" />
<meta charset="UTF-8">
	<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
	<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
	<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

	<script type="text/javascript" >

		$(function () {

			// 如果当前登录页不是顶层窗口 把它设置为顶层窗口
			if(window.top !== window){
				window.top.location = window.location;
			}

			let temp = $("#loginAct");
			//页面加载完毕的时候 用户名栏自动获取焦点
			temp.focus();

			// 页面加载完毕的时候 清空文本框
			temp.val("");
			$("#loginPwd").val("");

			//	按钮绑定登录的方法
			$("#loginBtn").click(function () {
				login();
			});

			// 为当前窗口绑定键盘事件
			// event这个参数表示按下的键
			$(window).keydown(function (event) {

				// 如果敲击的键盘键值为13 代表敲击的是回车 调用登录方法
				if (event.keyCode === 13){
					login();
				}
			})

		});


		// 登录的方法
		function login() {
			let loginAct = $("#loginAct");
			let loginPwd = $("#loginPwd");
			if($.trim(loginAct.val()) === "" ){
				$("#msg").html("账号不能为空！");
				loginAct.focus();
				return false;
			}else if($.trim(loginPwd.val()) === ""){
				$("#msg").html("密码不能为空！");
				loginPwd.focus();
				return false;
			}

			// 发起ajax请求
			$.ajax({
				url: "settings/user/login.do",
				data:{"loginAct":loginAct.val(),"loginPwd":loginPwd.val()},
				type:"post",
				dataType:"json",
				success:function (result) {
					// flag为true 代表成功  跳转到操作页面页面
					if(result.code === 100){
						document.location = "workbench/index.jsp";
					}else{
						// flag为false 代表失败 提示msg信息
						$("#msg").html(result.message);
					}
				}
			});
		}
	</script>
	<title>ssm2</title>

</head>
<body>
	<div style="position: absolute; top: 0; left: 0; width: 60%;">
		<img src="image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;" alt="">
	</div>
	<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
		<div style="position: absolute; top: 5px; left: 0; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">SSM &nbsp;<span style="font-size: 12px;">@2021 动力节点原创</span></div>
	</div>
	
	<div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;border:1px solid #D5D5D5">
		<div style="position: absolute; top: 0; right: 60px;">
			<div class="page-header">
				<h1>登录</h1>
			</div>
			<form action="workbench/index.jsp" class="form-horizontal" role="form" method="post">
				<div class="form-group form-group-lg">
					<div style="width: 350px;">
						<label for="loginAct"></label><input class="form-control" type="text" placeholder="用户名" name="loginAct" id="loginAct"/>
					</div>
					<div style="width: 350px; position: relative;top: 20px;">
						<label for="loginPwd"></label><input class="form-control" type="password" placeholder="密码" name="loginPwd" id="loginPwd"/>
					</div>
					<div class="checkbox"  style="position: relative;top: 30px; left: 10px;">
						
							<span id="msg" style="color: red"></span>
						
					</div>
					<button id="loginBtn" type="button" class="btn btn-primary btn-lg btn-block"  style="width: 350px; position: relative;top: 45px;">登录</button>
				</div>
			</form>
		</div>
	</div>
</body>
</html>
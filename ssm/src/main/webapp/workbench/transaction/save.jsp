<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" +
request.getServerPort() + request.getContextPath() + "/";
	Map<String , String > pMap = (Map<String, String>) application.getAttribute("pMap");
	Set<String> keySet = pMap.keySet();
%>

<html lang="en">
<head>
	<base href="<%=basePath%>" />
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<%--<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>--%>
<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js" ></script>
<script type="text/javascript" >

	let json = {
	<%for(String key : keySet){
			String value = pMap.get(key);%>
		"<%=key%>" : <%=value%>,
	<%}%>
	};

	//日期控件
	(function($){
		$.fn.datetimepicker.dates['zh-CN'] = {
			days: ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日"],
			daysShort: ["周日", "周一", "周二", "周三", "周四", "周五", "周六", "周日"],
			daysMin:  ["日", "一", "二", "三", "四", "五", "六", "日"],
			months: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"],
			monthsShort: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"],
			today: "今天",
			suffix: [],
			meridiem: ["上午", "下午"]
		};
	}(jQuery));

	$(function () {
		<%if(request.getAttribute("msg") != null){%>
			alert("${requestScope.msg}");
		<%}%>
		// 添加时间文本输入控件
		$(".time-top").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "top-left"
		});

		$(".time").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "bottom-left"
		});

		// 自动补全客户名称 进入后台拿nameList
		$("#create-customerName").typeahead({
			source: function (query, process) {
				$.get(
						"workbench/transaction/getCustomerName.do",
						{ "name" : query },
						function (data) {
							process(data.extend.cList);
						},
						"json"
				);
			},
			delay: 1500
		});

		// 阶段和可能性映射展示
		$("#create-transactionStage").on("change",function () {
			let stage = $("#create-transactionStage").val();
			/*
			在这里以json.key的形式不能取得value，因为这里的stage是一个可变变量
			如果是这样的key，那么就不能以传统的json.key方式来取值
			要用json[stage]形式来取
			 */
			$("#create-possibility").val(json[stage]);
		});

		// 单击保存按钮提交表单
		$("#saveBtn").on("click",function () {
			$("#TranForm").submit();
		})

		//关联的联系人模态窗口搜索栏绑定keydown事件  进入后台模糊查询条件
		$("#getContacts").keydown(function (e) {
			if(e.keyCode === 13) {
				$.ajax({
					url:"workbench/transaction/getContactsByName.do",
					data:{
						"name":$.trim($("#getContacts").val())

					},
					type:"get",
					dataType:"json",
					success:function (data) {
						let html = "";
						$.each(data.extend.cList, function (index, element) {
							html += '<tr>'
							html += '<td>'
							html += '<input type="radio" name="xz" value="'+element.id+'"/></td>'
							html += '<td id="'+element.id+'">'+element.fullname+'</td>'
							html += '<td>'+element.email+'</td>'
							html += '<td>'+element.mphone+'</td>'
							html += '</tr>'
						});
						$("#searchCBody").html(html);
					}
				});
				// 阻止关闭该模态窗口
				return false;
			}
		});

		//打开联系人模态框
		$("#openSearch1").click(function (){
			$("#findContacts").modal("show");
		});

		// 单击搜索联系人中的提交将选中项提交到联系人
		$("#submitBtn").on("click",function () {
			// 隐藏域中保存选中的市场活动的id
			let id = $("input[name=xz]:checked").val();
			$("#hidden-contactsName").val(id);
			$("#create-contactsName").val($("#" + id).html());
			$("#findContacts").modal("hide");
			$("#searchCBody").empty();
		});

		//关联的市场活动源模态窗口搜索栏绑定keydown事件  进入后台模糊查询条件
		$("#getActivities").keydown(function (e) {
			// 按下回车键
			if(e.keyCode === 13){
				// alert("按下了回车！");
				// alert($("#getActivities").val());
				$.ajax({
					url:"workbench/transaction/getAcByName.do",
					data:{
						"name":$.trim($("#getActivities").val())
					},
					type:"get",
					dataType:"json",
					success:function (data) {
						// 显示模糊查询出来的activity
						let html = "";
						$.each(data.extend.acList , function (index,element) {
							html += '<tr>';
							html += '<td><input type="radio" name="xz2" value="'+element.id+'"/></td>';
							html += '<td id="'+element.id+'">'+element.name+'</td>';
							html += '<td>'+element.startDate+'</td>';
							html += '<td>'+element.endDate+'</td>';
							html += '<td>'+element.owner+'</td>';
							html += '</tr>';
						});
						$("#searchACBody").html(html);
					}
				});
				// 阻止关闭该模态窗口
				return false;
			}
		});

		// 单击搜索联系人中的提交将选中项提交到联系人
		$("#submitBtn2").on("click",function () {
			// 隐藏域中保存选中的市场活动的id
			let id = $("input[name=xz2]:checked").val();
			$("#hidden-activitySrc").val(id);
			$("#create-activitySrc").val($("#" + id).html());
			$("#findMarketActivity").modal("hide");
			$("#searchACBody").empty();
		});
	})

</script>
	<title>ssm2</title>
</head>
<body>

	<!-- 查找市场活动 -->	
	<div class="modal fade" id="findMarketActivity" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
							  <label for="getActivities">
								  <input type="text" id="getActivities" class="form-control" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
							  </label>
							  <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable3" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
							</tr>
						</thead>
						<tbody id="searchACBody">

						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-primary" id="submitBtn2">提交</button>
				</div>
			</div>
		</div>
	</div>

	<!-- 查找联系人 -->	
	<div class="modal fade" id="findContacts" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找联系人</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
							  <label for="getContacts">
								  <input type="text" class="form-control" id="getContacts" style="width: 300px;" placeholder="请输入联系人名称，支持模糊查询">
							  </label>
							  <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>邮箱</td>
								<td>手机</td>
							</tr>
						</thead>
						<tbody id="searchCBody">
						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-primary" id="submitBtn">提交</button>
				</div>
			</div>
		</div>
	</div>
	
	
	<div style="position:  relative; left: 30px;">
		<h3>创建交易</h3>
	  	<div style="position: relative; top: -40px; left: 70%;">
			<button type="button" class="btn btn-primary" id="saveBtn">保存</button>
			<button type="button" class="btn btn-default">取消</button>
		</div>
		<hr style="position: relative; top: -40px;">
	</div>
	<form class="form-horizontal" role="form" id="TranForm" style="position: relative; top: -30px;" method="post" action="workbench/transaction/saveTran.do">
		<input type="hidden" name="createBy" value="${sessionScope.user.name}"/>
		<div class="form-group">
			<label for="create-transactionOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-transactionOwner" name="owner">
					<option></option>
					<c:forEach items="${requestScope.userList}" var="u" >
						<option value="${u.id}" ${sessionScope.user.id eq u.id ? "selected" : ""}>${u.name}</option>
					</c:forEach>
				</select>
			</div>
			<label for="create-amountOfMoney" class="col-sm-2 control-label">金额</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-amountOfMoney" name="money">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-transactionName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-transactionName" name="name">
			</div>
			<label for="create-expectedClosingDate" class="col-sm-2 control-label">预计成交日期<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control time" id="create-expectedClosingDate" name="expectedDate">
			</div>
		</div>
		
		<div class="form-group">
			<label class="col-sm-2 control-label">客户名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<label for="create-customerName"></label><input type="text" class="form-control" id="create-customerName" name="customerName" placeholder="支持自动补全，输入客户不存在则新建">
			</div>
			<label for="create-transactionStage" class="col-sm-2 control-label">阶段<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
			  <select class="form-control" id="create-transactionStage" name="stage">
			  	<option></option>
			  	<c:forEach items="${applicationScope.stage}" var="s" >
					<option value="${s.value}" >${s.text}</option>
				</c:forEach>
			  </select>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-transactionType" class="col-sm-2 control-label">类型</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-transactionType" name="type">
				  <option></option>
					<c:forEach items="${applicationScope.transactionType}" var="type" >
						<option value="${type.value}">${type.text}</option>
					</c:forEach>
				</select>
			</div>
			<label for="create-possibility" class="col-sm-2 control-label">可能性</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-possibility" >
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-clueSource" class="col-sm-2 control-label">来源</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-clueSource" name="source">
				  <option></option>
				 <c:forEach items="${applicationScope.source}" var="source" >
					 <option value="${source.value}" >${source.text}</option>
				 </c:forEach>
				</select>
			</div>
			<label for="create-activitySrc" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" data-toggle="modal" data-target="#findMarketActivity"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-activitySrc">
				<input type="hidden" id="hidden-activitySrc" name="activityId">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactsName" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a href="javascript:void(0);" id="openSearch1"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-contactsName" name="contactsName">
				<input type="hidden" name="contactsId" id="hidden-contactsName">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-describe" class="col-sm-2 control-label">描述</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" name="description" rows="3" id="create-describe"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-contactSummary" name="contactSummary"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control time-top" id="create-nextContactTime" name="nextContactTime">
			</div>
		</div>
		
	</form>
</body>
</html>
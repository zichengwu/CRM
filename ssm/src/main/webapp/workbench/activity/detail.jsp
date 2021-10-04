
<%@ page contentType="text/html;charset=UTF-8" %>
<%
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" +
	request.getServerPort() + request.getContextPath() + "/";
%>

<html lang="en">
<head>
	<base href="<%=basePath%>" />
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	let cancelAndSaveBtnDefault = true;
	$(function(){
		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});
		
		let ele1 = $(".remarkDiv");
		ele1.mouseover(function(){
			$(this).children("div").children("div").show();
		});
		
		ele1.mouseout(function(){
			$(this).children("div").children("div").hide();
		});
		
		let ele2 = $(".myHref")
		ele2.mouseover(function(){
			$(this).children("span").css("color","red");
		});
		
		ele2.mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});

		// 页面加载完毕后 动态的刷新备注栏
		showRemark();

		// 给保存按钮绑定事件
        $("#addRemarkBtn").on("click",function () {

            let $remark = $("#remark").val();
            if($remark.trim() === ""){
                alert("请填写备注信息");
            }else {
                $.ajax({
                    url:"workbench/activity/saveRemark.do",
                    data:{
                        "noteContent":$remark,
                        "createBy":"${sessionScope.user.name}",
                        "activityId":"${activity.id}",
                    },
                    type:"post",
                    dataType:"json",
                    success:function (data) {
                        if(data.code === 100){
                            // 追加一条记录上去
                            // 拿到回传的备注之后进行标签拼接
                            let html = "";
                            html +=  '<div id="'+data.extend.remark.id+'" class="remarkDiv" style="height: 60px;">';
                            html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;" alt="">';
                            html += '<div style="position: relative; top: -40px; left: 40px;" >';
                            html += '<h5 id="e'+data.extend.remark.id+'">'+data.extend.remark.noteContent+'</h5>';
                            html += '<font color="gray">市场活动-</font> <b>${activity.name}</b> <small style="color: gray;" id="s'+data.extend.remark.id+'">'+data.extend.remark.createTime+' 由'+data.extend.remark.createBy+'</small>';
                            html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
                            html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+data.extend.remark.id+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF0000;"></span></a>';
                            html += '&nbsp;&nbsp;&nbsp;&nbsp;';
                            html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+data.extend.remark.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
                            html += '</div>';
                            html += '</div>';
                            html += '</div>';

                            // 将拼接完成的标签插入
                            $("#assist").after(html);
                            //清空文本栏
                            $("#remark").val("");
                        }else {
                            alert("添加失败！")
                        }
                    }
                })
            }
        });

        // 给更新按钮绑定事件
        $("#updateRemarkBtn").on("click",function () {

            let $remark = $.trim($("#noteContent").val());
            let id = $("#remarkId").val();
            if($remark === ""){
                alert("请填写备注信息");
            }else {
                $.ajax({
                    url:"workbench/activity/updateRemark.do",
                    data:{
                        "id":id,
                        "noteContent":$remark,
                        "editBy":"${sessionScope.user.name}"
                    },
                    dataType:"json",
                    type:"post",
                    success:function (data) {
                        if(data.code === 100){
                            // 隐藏模态窗口
                            $("#editRemarkModal").modal("hide");

                            // 更新div中得信息，需要更新的内容有noteContent,editTime,editBy
                            $("#e" + id).html(data.extend.ar.noteContent);
                            $("#s" + id).html(data.extend.ar.editTime + "由" + data.extend.ar.editBy);

                            // 清空备注信息
                            $remark.val("");
                        }else {
                            alert("修改失败！");
                        }
                    }
                });
            }
        })
	});

	// 动态刷新备注
	function showRemark() {

		$.ajax({
			url:"workbench/activity/getRemark.do",
			data:{
				"activityId":"${activity.id}"
			},
			type:"get",
			dataType:"json",
			success:function (data) {
				// 拿到回传的备注之后进行标签拼接
				let html = "";
				$.each(data.extend.list , function (index , element) {
				 	html +=  '<div id="'+element.id+'" class="remarkDiv" style="height: 60px;">';
					html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;" alt="">';
					html += '<div style="position: relative; top: -40px; left: 40px;" >';
					html += '<h5 id="e'+element.id+'">'+element.noteContent+'</h5>';
					html += '<font color="gray">市场活动-</font> <b>${activity.name}</b> <small style="color: gray;" id="s'+element.id+'">'+(element.editFlag===1?element.editTime:element.createTime)+' 由'+(element.editFlag===1?element.editBy:element.createBy)+'</small>';
					html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
					html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+element.id+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF0000;"></span></a>';
					html += '&nbsp;&nbsp;&nbsp;&nbsp;';
                    // 动态生成的html语句中事件传值需要在引号中传值 硬性规定
                    // onclick="deleteRemark(\''+element.id+'\')
					html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+element.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
					html += '</div>';
					html += '</div>';
					html += '</div>';
				});
				// 将拼接完成的标签插入
				$("#remarkDiv").before(html);   //在id为remarkDiv的标签之前插入
			}
		});

        // 动态更新出来两个按钮
		let ele3 = $("#remarkBody");
        ele3.on("mouseover",".remarkDiv",function(){
            $(this).children("div").children("div").show();
        });
        ele3.on("mouseout",".remarkDiv",function(){
            $(this).children("div").children("div").hide();
        })
    }

    // 打开修改备注的模态窗口
    function editRemark(id){
        // 保存id值
	    $("#remarkId").val(id);
	    let noteContent = $("#e" + id).html();
	    $("#noteContent").val(noteContent);
        // 展示模态窗口
        $("#editRemarkModal").modal("show");
    }

	// 根据id删除remark
	function deleteRemark(id) {
	    if(confirm("确定删除这条备注吗？")){
            // 发起ajax请求
	        $.ajax({
                url:"workbench/activity/deleteRemark.do",
                data: {
                    "id":id
                },
                type: "post",
                dataType:"json",
                success:function (data) {
                    if(data.code === 100){
                        // 删除该备注
                        $("#" + id).remove();
                    }else {
                        alert("删除失败！");
                    }
                }
            });
        }
    }
</script>
    <title>ssm2</title>
</head>
<body>
	
	<!-- 修改市场活动备注的模态窗口 -->
	<div class="modal fade" id="editRemarkModal" role="dialog">
		<%-- 备注的id 也就是市场活动id，是市场活动备注的外键 --%>
		<input type="hidden" id="remarkId">
        <div class="modal-dialog" role="document" style="width: 40%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">修改备注</h4>
                </div>
                <div class="modal-body">
                    <form class="form-horizontal" role="form">
                        <div class="form-group">
                            <label class="col-sm-2 control-label">内容</label>
                            <div class="col-sm-10" style="width: 81%;">
								<label for="noteContent"></label><textarea class="form-control" rows="3" id="noteContent"></textarea>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
                </div>
            </div>
        </div>
    </div>

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>市场活动-${activity.name} <small>${activity.startDate} ~ ${activity.endDate}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;"></div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${activity.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>

		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">开始日期</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.startDate}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">结束日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${activity.endDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">成本</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.cost}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${activity.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${activity.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${activity.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${activity.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${activity.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 备注 -->
	<div style="position: relative; top: 30px; left: 40px;" id="remarkBody">
		<div class="page-header" id="assist">
			<h4>备注</h4>
		</div>
		
		<%--<!-- 备注1 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;" alt="">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
		
		<!-- 备注2 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;" alt="">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>--%>
		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<label for="remark"></label><textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2" placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" id="addRemarkBtn" class="btn btn-primary">保存</button>
				</p>
			</form>
		</div>
	</div>
	<div style="height: 200px;"></div>
</body>
</html>
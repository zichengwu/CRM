<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" +
            request.getServerPort() + request.getContextPath() + "/";
%>

<html lang="en">
<head>
    <base href="<%=basePath%>"/>
    <meta charset="UTF-8">

    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

    <script type="text/javascript">

        //默认情况下取消和保存按钮是隐藏的
        let cancelAndSaveBtnDefault = true;

        $(function () {
            $("#remark").focus(function () {
                if (cancelAndSaveBtnDefault) {
                    //设置remarkDiv的高度为130px
                    $("#remarkDiv").css("height", "130px");
                    //显示
                    $("#cancelAndSaveBtn").show("2000");
                    cancelAndSaveBtnDefault = false;
                }
            });

            $("#cancelBtn").click(function () {
                //显示
                $("#cancelAndSaveBtn").hide();
                //设置remarkDiv的高度为130px
                $("#remarkDiv").css("height", "90px");
                cancelAndSaveBtnDefault = true;
            });

            let ele1 = $(".remarkDiv");
            ele1.mouseover(function () {
                $(this).children("div").children("div").show();
            });

            ele1.mouseout(function () {
                $(this).children("div").children("div").hide();
            });

            let ele2 = $(".myHref");
            ele2.mouseover(function () {
                $(this).children("span").css("color", "red");
            });

            ele2.mouseout(function () {
                $(this).children("span").css("color", "#E6E6E6");
            });

            // 全选框
            $("#qx").on("click", function () {
                $("input[name=xz]").prop("checked", this.checked);
            });

            // 动态生成的标绑定单击事件的用法
            // 下面是外层有效标签的jQuery对象（不是动态生成的标签）
            $("#searchAcBody").on("click", $("input[name=xz]"), function () {
                // 这里表示选择框的总数量等于被选选择框的数量 那么全选框就勾选 否则就不勾选
                $("#qx").prop("checked", $("input[name=xz]").length === $("input[name=xz]:checked").length);
            });


            // 打开页面的时候刷新市场活动列表
            showActivity();


            //关联的模态窗口搜索栏绑定keydown事件  进入后台模糊查询条件
            $("#getActivities").keydown(function (e) {
                // 通过回车键触发查询
                if (e.keyCode === 13) {
                    // alert("按下了回车！");
                    // alert($("#getActivities").val());
                    $.ajax({
                        url: "workbench/clue/getAcByNameAndNotBind.do",
                        data: {
                            "name": $.trim($("#getActivities").val()),
                            "clueId": "${requestScope.clue.id}"
                        },
                        type: "get",
                        dataType: "json",
                        success: function (data) {
                            // 显示模糊查询出来的activity
                            let html = "";
                            $.each(data.extend.AcList, function (index, element) {
                                html += '<tr>';
                                html += '<td><input type="checkbox" name="xz" value="' + element.id + '"/></td>';
                                html += '<td>' + element.name + '</td>';
                                html += '<td>' + element.startDate + '</td>';
                                html += '<td>' + element.endDate + '</td>';
                                html += '<td>' + element.owner + '</td>';
                                html += '</tr>';
                            });
                            $("#searchAcBody").html(html);
                        }
                    });
                    // 模态窗口默认按完回车后页面所有数据清空，下面的语句阻止关闭该模态窗口
                    return false;
                }
            });

            // 关联按钮绑定事件
            $("#saveBtn").on("click", function () {
                // 获取选择到的市场活动
                const $xz = $("input[name=xz]:checked");
                if ($xz.length === 0) {
                    alert("请选择需要关联的市场活动");
                } else {
                    // 拼接参数
                    let param = "clueId=${requestScope.clue.id}&";
                    for (let i = 0; i < $xz.length; i++) {
                        param += "id=" + $xz[i].value;
                        if (i < $xz.length - 1) {
                            param += "&";
                        }
                    }
                    //发起ajax请求
                    $.ajax({
                        url: "workbench/clue/bindAC.do",
                        data: param,
                        dataType: "json",
                        type: "post",
                        success: function (data) {
                            if (data.code === 100) {
                                // 清空和关闭窗口
                                $("#searchAcBody").html("");
                                $("#bundModal").modal("hide");
                                $("#getActivities").val("");
                                $("#qx").prop("checked", false);
                                // 刷新列表
                                showActivity();
                            } else {
                                alert(data.message);
                            }
                        }
                    });
                }
            })
        });

        // 展示市场活动列表
        function showActivity() {
            $.ajax({
                url: "workbench/clue/showActivityByClueId.do",
                data: {
                    "id": "${requestScope.clue.id}"
                },
                dataType: "json",
                type: "get",
                success: function (data) {
                    // 返回的data是关联的市场活动列表
                    let html = "";
                    $.each(data.extend.list, function (index, element) {
                        html += '<tr id="' + element.id + '">';
                        html += '<td>' + element.name + '</td>';
                        html += '<td>' + element.startDate + '</td>';
                        html += '<td>' + element.endDate + '</td>';
                        html += '<td>' + element.owner + '</td>';
                        //id指的是市场活动，线索关联关系表的id，因为要删除的是关联关系，不是删除市场活动
                        html += '<td><a href="javascript:void(0);" onclick="unBind(\'' + element.id + '\')" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>';
                        html += '</tr>';
                    });
                    // 显示列表
                    $("#activityBody").html(html);
                }
            });
        }

        // 根据关联关系表删除一条关联记录
        function unBind(id) {
            $.ajax({
                url: "workbench/clue/unBindAC.do",
                data: {
                    "id": id
                },
                type: "post",
                dataType: "json",
                success: function (data) {
                    if (data.code === 100) {
                        $("#" + id).remove();
                    } else {
                        alert("删除失败！");
                    }
                }
            });
        }

    </script>
    <title>ssm2</title>

</head>
<body>

<!-- 关联市场活动的模态窗口 -->
<div class="modal fade" id="bundModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 80%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">关联市场活动</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <form class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <label for="getActivities"></label><input type="text" class="form-control"
                                                                      style="width: 300px;" id="getActivities"
                                                                      placeholder="请输入市场活动名称，支持模糊查询">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </form>
                </div>
                <table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td><label for="qx"></label><input type="checkbox" id="qx"/></td>
                        <td>名称</td>
                        <td>开始日期</td>
                        <td>结束日期</td>
                        <td>所有者</td>
                        <td></td>
                    </tr>
                    </thead>
                    <tbody id="searchAcBody">
                    <<%--tr>
								<td><input type="checkbox"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>
							<tr>
								<td><input type="checkbox"/></td>
								<td>发传单</td>
								<td>2020-10-10</td>
								<td>2020-10-20</td>
								<td>zhangsan</td>
							</tr>--%>
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <button type="button" class="btn btn-primary" id="saveBtn">关联</button>
            </div>
        </div>
    </div>
</div>

<!-- 返回按钮 -->
<div style="position: relative; top: 35px; left: 10px;">
    <a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left"
                                                                         style="font-size: 20px; color: #DDDDDD"></span></a>
</div>

<!-- 大标题 -->
<div style="position: relative; left: 40px; top: -30px;">
    <div class="page-header">
        <h3>${requestScope.clue.fullname}${clue.appellation} <small>${clue.company}</small></h3>
    </div>
    <div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">
        <button type="button" class="btn btn-default"
                onclick="window.location.href='workbench/clue/convert.jsp?clueId=${clue.id}&fullname=${clue.fullname}&appellation=${clue.appellation}&company=${clue.company}&owner=${clue.owner}';">
            <span class="glyphicon glyphicon-retweet"></span> 转换
        </button>
    </div>
</div>

<!-- 详细信息 -->
<div style="position: relative; top: -70px;">
    <div style="position: relative; left: 40px; height: 30px;">
        <div style="width: 300px; color: gray;">名称</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;">
            <b>${requestScope.clue.fullname}${clue.appellation}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">所有者</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.owner}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 10px;">
        <div style="width: 300px; color: gray;">公司</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.company}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">职位</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.job}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 20px;">
        <div style="width: 300px; color: gray;">邮箱</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.email}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">公司座机</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.phone}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 30px;">
        <div style="width: 300px; color: gray;">公司网站</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.website}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">手机</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.mphone}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 40px;">
        <div style="width: 300px; color: gray;">线索状态</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.state}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">线索来源</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${clue.source}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 50px;">
        <div style="width: 300px; color: gray;">创建者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${clue.createBy}&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;">${clue.createTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 60px;">
        <div style="width: 300px; color: gray;">修改者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${clue.editBy}&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;">${clue.editTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 70px;">
        <div style="width: 300px; color: gray;">描述</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                ${clue.description}
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 80px;">
        <div style="width: 300px; color: gray;">联系纪要</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                ${clue.contactSummary}
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 90px;">
        <div style="width: 300px; color: gray;">下次联系时间</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${clue.nextContactTime}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px; "></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 100px;">
        <div style="width: 300px; color: gray;">详细地址</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                ${clue.address}
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
</div>

<!-- 备注 -->
<div style="position: relative; top: 40px; left: 40px;">
    <div class="page-header">
        <h4>备注</h4>
    </div>
    <!-- 备注1 -->
    <div class="remarkDiv" style="height: 60px;">
        <img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;" alt="">
        <div style="position: relative; top: -40px; left: 40px;">
            <h5>哎呦！</h5>
            <font color="gray">线索</font> <font color="gray">-</font> <b>李四先生-动力节点</b> <small style="color: gray;">
            2017-01-22 10:10:10 由zhangsan</small>
            <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
            </div>
        </div>
    </div>
    <!-- 备注2 -->
    <div class="remarkDiv" style="height: 60px;">
        <img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;" alt="">
        <div style="position: relative; top: -40px; left: 40px;">
            <h5>呵呵！</h5>
            <font color="gray">线索</font> <font color="gray">-</font> <b>李四先生-动力节点</b> <small style="color: gray;">
            2017-01-22 10:20:10 由zhangsan</small>
            <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove"
                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>
            </div>
        </div>
    </div>
    <div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
        <form role="form" style="position: relative;top: 10px; left: 10px;">
            <label for="remark"></label><textarea id="remark" class="form-control" style="width: 850px; resize : none;"
                                                  rows="2" placeholder="添加备注..."></textarea>
            <p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
                <button id="cancelBtn" type="button" class="btn btn-default">取消</button>
                <button type="button" class="btn btn-primary">保存</button>
            </p>
        </form>
    </div>
</div>

<!-- 市场活动 -->
<div>
    <div style="position: relative; top: 60px; left: 40px;">
        <div class="page-header">
            <h4>市场活动</h4>
        </div>
        <div style="position: relative;top: 0;">
            <table class="table table-hover" style="width: 900px;">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td>名称</td>
                    <td>开始日期</td>
                    <td>结束日期</td>
                    <td>所有者</td>
                    <td></td>
                </tr>
                </thead>
                <tbody id="activityBody">
                <%--						<tr>--%>
                <%--							<td>发传单</td>--%>
                <%--							<td>2020-10-10</td>--%>
                <%--							<td>2020-10-20</td>--%>
                <%--							<td>zhangsan</td>--%>
                <%--							<td><a href="javascript:void(0);"  style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>--%>
                <%--						</tr>--%>
                <%--						<tr>--%>
                <%--							<td>发传单</td>--%>
                <%--							<td>2020-10-10</td>--%>
                <%--							<td>2020-10-20</td>--%>
                <%--							<td>zhangsan</td>--%>
                <%--							<td><a href="javascript:void(0);"  style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>--%>
                <%--						</tr>--%>
                </tbody>
            </table>
        </div>
        <div>
            <a href="javascript:void(0);" data-toggle="modal" data-target="#bundModal"
               style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>关联市场活动</a>
        </div>
    </div>
</div>
<div style="height: 200px;"></div>
</body>
</html>
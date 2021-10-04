package com.cheng.ssm.workbench.dao;

import com.cheng.ssm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface TranDao {

    int saveTran(Tran tran);

    List<Tran> getPageList();

    Tran selectDetail(String id);

    int updateStage(Tran tran);

    int getTotal();

    List<Map<String, Object>> getCharts();
}

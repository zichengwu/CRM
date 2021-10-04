package com.cheng.ssm.workbench.service;

import com.cheng.ssm.workbench.domain.Tran;
import com.cheng.ssm.workbench.domain.TranHistory;

import java.util.List;
import java.util.Map;

public interface TranService {

    List<Tran> getPageList();

    int saveTran(Tran tran, String customerName, String contactsName);

    Tran detail(String id);

    List<TranHistory> getHistoryListByTranId(String id);

    boolean updateStage(Tran tran);

    Map<String, Object> getCharts();

}

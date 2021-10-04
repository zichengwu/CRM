package com.cheng.ssm.workbench.dao;

import com.cheng.ssm.workbench.domain.TranHistory;

import java.util.List;

public interface TranHistoryDao {

    int saveTranHistory(TranHistory tranHistory);

    List<TranHistory> selectHistoryByTranId(String id);
}

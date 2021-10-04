package com.cheng.ssm.workbench.service.impl;

import com.cheng.ssm.exception.ChangeStageException;
import com.cheng.ssm.exception.TranSaveException;
import com.cheng.ssm.utils.DateTimeUtil;
import com.cheng.ssm.utils.UUIDUtil;
import com.cheng.ssm.workbench.dao.ContactsDao;
import com.cheng.ssm.workbench.dao.CustomerDao;
import com.cheng.ssm.workbench.dao.TranDao;
import com.cheng.ssm.workbench.dao.TranHistoryDao;
import com.cheng.ssm.workbench.domain.Contacts;
import com.cheng.ssm.workbench.domain.Customer;
import com.cheng.ssm.workbench.domain.Tran;
import com.cheng.ssm.workbench.domain.TranHistory;
import com.cheng.ssm.workbench.service.TranService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class TranServiceImpl implements TranService {

    @Resource
    private TranDao tranDao;

    @Resource
    private TranHistoryDao tranHistoryDao;

    @Resource
    private CustomerDao customerDao;

    @Resource
    private ContactsDao contactsDao;

    @Override
    public List<Tran> getPageList() {

        return tranDao.getPageList();
    }

    @Override
    public int saveTran(Tran tran, String customerName, String contactsName) {
        //先根据客户名称查询客户信息,若客户不存在就创建一个
        Customer customer = customerDao.selectCusByName(customerName);
        int result;
        // 该客户不存在则创建客户
        if (customer == null){
            customer = new Customer();
            customer.setId(UUIDUtil.getUUID());
            customer.setName(customerName);
            customer.setCreateBy(tran.getCreateBy());
            customer.setCreateTime(DateTimeUtil.getSysTime());
            customer.setOwner(tran.getOwner());
            customer.setNextContactTime(tran.getNextContactTime());
            customer.setContactSummary(tran.getContactSummary());
            result = customerDao.save(customer);
            if(result != 1){
                throw  new TranSaveException("客户创建失败，交易保存失败");
            }
        }
        Contacts contacts = contactsDao.getOneContactsByName(customerName);
        if (contacts == null) {
            contacts = new Contacts();
            contacts.setId(UUIDUtil.getUUID());
            contacts.setCustomerId(customer.getId());
            contacts.setFullname(contactsName);
            contacts.setCreateBy(tran.getCreateBy());
            contacts.setCreateTime(DateTimeUtil.getSysTime());
            contacts.setOwner(tran.getOwner());
            contacts.setSource(tran.getSource());
            contacts.setNextContactTime(tran.getNextContactTime());
            contacts.setContactSummary(tran.getContactSummary());
            result = contactsDao.save(contacts);
            if(result != 1){
                throw  new TranSaveException("联系人创建失败，交易保存失败");
            }
        }
        // 设置客户id
        tran.setContactsId(contacts.getId());
        tran.setCustomerId(customer.getId());
        tran.setId(UUIDUtil.getUUID());
        tran.setCreateTime(DateTimeUtil.getSysTime());
        result =  tranDao.saveTran(tran);
        if(result != 1){
            throw  new TranSaveException("交易保存失败");
        }
        // 添加交易历史
        TranHistory tranHistory = new TranHistory();
        tranHistory.setId(UUIDUtil.getUUID());
        tranHistory.setTranId(tran.getId());
        tranHistory.setStage(tran.getStage());
        tranHistory.setMoney(tran.getMoney());
        tranHistory.setExpectedDate(tran.getExpectedDate());
        tranHistory.setCreateTime(DateTimeUtil.getSysTime());
        tranHistory.setCreateBy(tran.getCreateBy());

        result = tranHistoryDao.saveTranHistory(tranHistory);
        if(result != 1){
            throw  new TranSaveException("交易历史创建失败");
        }
        return result;
    }

    @Override
    public Tran detail(String id) {
        return tranDao.selectDetail(id);
    }

    @Override
    public List<TranHistory> getHistoryListByTranId(String id) {
        return tranHistoryDao.selectHistoryByTranId(id);
    }

    @Override
    @Transactional
    public boolean updateStage(Tran tran) {
        tran.setEditTime(DateTimeUtil.getSysTime());
        int result = tranDao.updateStage(tran);
        if(result != 1){
            throw new ChangeStageException("改变交易阶段失败");
        }
        //创建交易历史
        TranHistory history = new TranHistory();
        history.setCreateTime(DateTimeUtil.getSysTime());
        history.setCreateBy(tran.getEditBy());
        history.setId(UUIDUtil.getUUID());
        history.setStage(tran.getStage());
        history.setTranId(tran.getId());
        history.setMoney(tran.getMoney());
        history.setExpectedDate(tran.getExpectedDate());

        result = tranHistoryDao.saveTranHistory(history);
        if(result != 1){
            throw new ChangeStageException("创建交易历史失败");
        }
        return true;
    }

    @Override
    public Map<String, Object> getCharts() {
        int total = tranDao.getTotal();
        List<Map<String, Object>> dataList = tranDao.getCharts();
        Map<String, Object> map = new HashMap<>();
        map.put("total", total);
        map.put("dataList", dataList);
        return map;
    }
}

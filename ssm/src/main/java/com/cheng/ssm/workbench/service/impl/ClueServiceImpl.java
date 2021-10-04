package com.cheng.ssm.workbench.service.impl;

import com.cheng.ssm.exception.BindException;
import com.cheng.ssm.exception.ConvertException;
import com.cheng.ssm.utils.DateTimeUtil;
import com.cheng.ssm.utils.UUIDUtil;
import com.cheng.ssm.workbench.dao.*;
import com.cheng.ssm.workbench.domain.*;
import com.cheng.ssm.workbench.service.ClueService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ClueServiceImpl implements ClueService {

    //线索相关表
    @Resource
    private ClueDao clueDao;

    @Resource
    private ClueActivityRelationDao clueActivityRelationDao;

    @Resource
    private ClueRemarkDao clueRemarkDao;

    //客户相关表
    @Resource
    private CustomerDao customerDao;

    @Resource
    private CustomerRemarkDao customerRemarkDao;

    //联系人相关表
    @Resource
    private ContactsDao contactsDao;

    @Resource
    private ContactsRemarkDao contactsRemarkDao;

    @Resource
    private ContactsActivityRelationDao contactsActivityRelationDao;

    //交易相关表
    @Resource
    private TranDao tranDao;

    @Resource
    private TranHistoryDao tranHistoryDao;


    @Override
    public boolean saveClue(Clue clue) {

        // 设置基础值
        clue.setCreateTime(DateTimeUtil.getSysTime());
        clue.setId(UUIDUtil.getUUID());

        return 1 == clueDao.insertClue(clue);
    }

    @Override
    public List<Clue> getPageList() {
        return clueDao.getPageList();
    }

    @Override
    public Clue getClueById(String id) {
        return clueDao.getClueById(id);
    }

    @Override
    public boolean deleteACRelation(String id) {
        return 1 == clueActivityRelationDao.deleteACRelation(id);
    }

    //根据线索id和市场活动id进行关联
    @Override
    @Transactional
    public boolean bind(String clueId, String[] ids) {

        //存储查询条件
        Map<String , String> map = new HashMap<>();
        // 获取需要插入的条数
        int total = ids.length;
        map.put("clueId",clueId);
        int result = 0 ;
        for (String id: ids) {
            //也可以通过创建实体类对象来完成赋值
            map.put("id", UUIDUtil.getUUID());
            map.put("activityId", id);
            result += clueActivityRelationDao.insertCARelation(map);
        }
        if(total != result){
            throw new BindException("未能完全插入，请重试！");
        }
        return true;
    }

    //将线索转换为客户和联系人
    @Override
    @Transactional
    public void convert(String clueId, Tran tran, String createBy) {

        String createTime = DateTimeUtil.getSysTime();
        int result = 0;
        // （1）通过线索id拿到线索完整信息
        Clue clue = clueDao.selectClueById(clueId);

        // （2）通过线索信息提取客户(公司)信息，若客户不存在就新建（通过公司的名字精确匹配来判断客户是否存在）
        String company = clue.getCompany();
        Customer customer = customerDao.selectCusByName(company);
        if(customer == null) {
            customer = new Customer();
            customer.setId(UUIDUtil.getUUID());
            customer.setOwner(clue.getOwner());
            customer.setName(company);
            customer.setWebsite(clue.getWebsite());
            customer.setPhone(clue.getPhone());
            customer.setCreateBy(createBy);
            customer.setCreateTime(createTime);
            customer.setContactSummary(clue.getContactSummary());
            customer.setNextContactTime(clue.getNextContactTime());
            customer.setDescription(clue.getDescription());
            customer.setAddress(clue.getAddress());
            //添加客户
            result = customerDao.save(customer);
        }
        // 创建失败则抛出异常回滚事务
        if(result != 1){
            throw new ConvertException("客户添加失败，转换失败");
        }

        // （3）通过线索对象提取联系人信息 保存联系人
        Contacts contacts = new Contacts();
        contacts.setId(UUIDUtil.getUUID());
        contacts.setFullname(clue.getFullname());
        contacts.setAppellation(clue.getAppellation());
        contacts.setOwner(clue.getOwner());
        contacts.setSource(clue.getSource());
        contacts.setCustomerId(customer.getId());
        contacts.setEmail(clue.getEmail());
        contacts.setMphone(clue.getMphone());
        contacts.setJob(clue.getJob());
        contacts.setCreateBy(createBy);
        contacts.setCreateTime(createTime);
        contacts.setContactSummary(clue.getContactSummary());
        contacts.setNextContactTime(clue.getNextContactTime());
        contacts.setDescription(clue.getDescription());
        contacts.setAddress(clue.getAddress());

        // 插入一条联系人信息
        result =  contactsDao.save(contacts);

        if(result != 1){
            throw new ConvertException("联系人添加失败，转换失败");
        }

        // (4)将线索备注转换为联系人备注和客户备注
        List<ClueRemark> clueRemarkList = clueRemarkDao.getClueRemarkByClueId(clueId);

        // 每取出一个线索备注 进行一次转换
        if(clueRemarkList != null) {
            for (ClueRemark clueRemark : clueRemarkList) {

                String noteContent = clueRemark.getNoteContent();

                ContactsRemark contactsRemark = new ContactsRemark();
                contactsRemark.setId(UUIDUtil.getUUID());
                contactsRemark.setContactsId(contacts.getId());
                contactsRemark.setCreateBy(createBy);
                contactsRemark.setCreateTime(createTime);
                contactsRemark.setNoteContent(noteContent);
                contactsRemark.setEditFlag("0");
                // 插入一条联系人备注记录
                result = contactsRemarkDao.saveContactsRemark(contactsRemark);
                if (result != 1) {
                    throw new ConvertException("联系人备注添加失败，转换失败");
                }

                CustomerRemark customerRemark = new CustomerRemark();
                customerRemark.setId(UUIDUtil.getUUID());
                customerRemark.setCustomerId(customer.getId());
                customerRemark.setCreateBy(createBy);
                customerRemark.setCreateTime(createTime);
                customerRemark.setNoteContent(noteContent);
                customerRemark.setEditFlag("0");
                // 插入一条客户备注记录
                result = customerRemarkDao.saveCustomerRemark(customerRemark);
                if (result != 1) {
                    throw new ConvertException("客户备注添加失败，转换失败");
                }
            }
        }

        // （5）线索和市场活动的关联关系转换到联系人和市场活动的关联关系
        // 查询该线索的所有市场活动关联
        List<ClueActivityRelation> clueActivityRelationList = clueActivityRelationDao.getRelationByClueId(clueId);

        // 依次插入联系人和市场活动的关联
        if(clueActivityRelationList != null){
            for(ClueActivityRelation clueActivityRelation : clueActivityRelationList){

                ContactsActivityRelation relation = new ContactsActivityRelation();
                relation.setId(UUIDUtil.getUUID());
                relation.setActivityId(clueActivityRelation.getActivityId());
                relation.setContactsId(contacts.getId());

                result = contactsActivityRelationDao.insertRelation(relation);
                if(result != 1){
                    throw new ConvertException("联系人和市场活动关联失败，转换失败");
                }
            }
        }

        // (6)当tran不为null时 需要添加交易
        if(tran != null) {
            //已封装好的信息：money,name,expectedDate,stage,activityId

            tran.setId(UUIDUtil.getUUID());
            tran.setOwner(clue.getOwner());
            tran.setCreateTime(createTime);
            tran.setCreateBy(createBy);
            tran.setSource(clue.getSource());
            tran.setContactsId(contacts.getId());
            tran.setCustomerId(customer.getId());
            tran.setNextContactTime(clue.getNextContactTime());
            tran.setDescription(clue.getDescription());
            tran.setContactSummary(clue.getContactSummary());

            // 添加交易
            result = tranDao.saveTran(tran);
            if (result != 1) {
                throw new ConvertException("交易添加失败，转换失败");
            }
            // (7)添加交易之后添加交易历史
            TranHistory tranHistory = new TranHistory();
            tranHistory.setId(UUIDUtil.getUUID());
            tranHistory.setCreateBy(createBy);
            tranHistory.setCreateTime(createTime);
            tranHistory.setTranId(tran.getId());
            tranHistory.setMoney(tran.getMoney());
            tranHistory.setExpectedDate(tran.getExpectedDate());
            tranHistory.setStage(tran.getStage());


            result = tranHistoryDao.saveTranHistory(tranHistory);
            if(result != 1){
                throw new ConvertException("交易历史添加失败，转换失败");
            }
        }

        // (8)删除线索备注
        if (clueRemarkList != null) {
            for(ClueRemark clueRemark : clueRemarkList){
                result = clueRemarkDao.deleteClueRemark(clueRemark.getId());
                if(result != 1){
                    throw new ConvertException("删除线索备注失败，转换失败");
                }
            }
        }

        // （9）删除线索和市场活动的关系
        if (clueActivityRelationList != null) {
            for(ClueActivityRelation clueActivityRelation : clueActivityRelationList){

                result = clueActivityRelationDao.deleteACRelation(clueActivityRelation.getId());
                if(result != 1){
                    throw new ConvertException("删除线索和市场活动关联关系失败，转换失败");
                }
            }
        }

        // （10）删除线索
        result = clueDao.deleteClueById(clueId);
        if(result != 1){
            throw new ConvertException("删除线索失败，转换失败");
        }
    }
}

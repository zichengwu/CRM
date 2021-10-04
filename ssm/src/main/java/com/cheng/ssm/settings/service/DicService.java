package com.cheng.ssm.settings.service;

import com.cheng.ssm.settings.domain.DicValue;

import java.util.List;
import java.util.Map;

public interface DicService {

    Map<String, List<DicValue>> getDicValue();
}

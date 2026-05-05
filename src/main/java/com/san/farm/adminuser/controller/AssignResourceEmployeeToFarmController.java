package com.san.farm.adminuser.controller;

import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService;
import com.san.farm.adminuser.dao.ConfigFarmTaskService;
import com.san.farm.adminuser.dao.EmployeeInfoService;
import com.san.farm.adminuser.entity.AssignCropToSiteEntity;
import com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity;
import com.san.farm.adminuser.entity.ConfigFarmTaskEntity;
import com.san.farm.adminuser.entity.EmployeeInfoEntity;

public class AssignResourceEmployeeToFarmController {
	private static final Logger logger = LoggerFactory.getLogger(AssignResourceEmployeeToFarmController.class);

	public void assignEmployeeToFarm(int employeeInfoId,String arrfarmTaskId[],double amount,double advPayment,Date assignWorkDate,String typeOfWork,String workStatus,String comment,AssignCropToSiteEntity cropToSiteEntity){
		logger.debug("Assigning employee {} to farm tasks", employeeInfoId);
		try{
			EmployeeInfoService employeeInfoService=new EmployeeInfoService();
			EmployeeInfoEntity employeeInfoEntity=employeeInfoService.getEmployeeById(employeeInfoId);
			AssignResourceEmployeeToFarmService resourceEmployeeToFarmService=new AssignResourceEmployeeToFarmService();
			ConfigFarmTaskService farmTaskService=new ConfigFarmTaskService();
			List<ConfigFarmTaskEntity> listFarmTaskEntities=new ArrayList<ConfigFarmTaskEntity>();

			for(int i=0;i<arrfarmTaskId.length;i++){
				ConfigFarmTaskEntity farmTaskEntity=farmTaskService.getFarmTaskIdByTaskId(Integer.parseInt(arrfarmTaskId[i]));
				listFarmTaskEntities.add(farmTaskEntity);
			}

			AssignEmployeeToFarmEntity employeeToFarm=new AssignEmployeeToFarmEntity();
			employeeToFarm.setEmployeeInfoEntity(employeeInfoEntity);
			employeeToFarm.setAssignWorkDate(assignWorkDate);
			employeeToFarm.setTypeOfWork(typeOfWork);
			employeeToFarm.setAmount(amount);
			employeeToFarm.setAdvPayment(advPayment);			
			employeeToFarm.setComment(comment);
			employeeToFarm.setWorkStatus(workStatus);
			employeeToFarm.setCropToSiteEntity(cropToSiteEntity);
			employeeToFarm.setListFarmTaskEntities(listFarmTaskEntities);			
			
			//insert operation
			logger.info("Saving employee {} assignment with amount: {}, advance: {}", employeeInfoId, amount, advPayment);
			resourceEmployeeToFarmService.saveEmployeeToFarm(employeeToFarm);
			logger.info("Employee assignment saved successfully");

		}catch(Exception exception){
			logger.error("Error assigning employee {} to farm", employeeInfoId, exception);
		}
	}
}

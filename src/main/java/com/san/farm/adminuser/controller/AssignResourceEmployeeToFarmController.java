package com.san.farm.adminuser.controller;

import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.san.farm.adminuser.dao.AssignResourceEmployeeToFarmService;
import com.san.farm.adminuser.dao.ConfigCropService;
import com.san.farm.adminuser.dao.ConfigFarmTaskService;
import com.san.farm.adminuser.dao.EmployeeInfoService;
import com.san.farm.adminuser.entity.AssignCropToSiteEntity;
import com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity;
import com.san.farm.adminuser.entity.ConfigCropEntity;
import com.san.farm.adminuser.entity.ConfigFarmTaskEntity;
import com.san.farm.adminuser.entity.EmployeeInfoEntity;

public class AssignResourceEmployeeToFarmController {
	private static final Logger logger = LoggerFactory.getLogger(AssignResourceEmployeeToFarmController.class);

	public void assignEmployeeToFarm(int employeeInfoId,String arrfarmTaskId[],double amount,double advPayment,Date assignWorkDate,String typeOfWork,String workStatus,String comment,AssignCropToSiteEntity cropToSiteEntity,int cropId){
		logger.debug("Assigning employee {} to farm tasks, cropId: {}", employeeInfoId, cropId);
		try{
			EmployeeInfoService employeeInfoService=new EmployeeInfoService();
			EmployeeInfoEntity employeeInfoEntity=employeeInfoService.getEmployeeById(employeeInfoId);
			AssignResourceEmployeeToFarmService resourceEmployeeToFarmService=new AssignResourceEmployeeToFarmService();
			ConfigFarmTaskService farmTaskService=new ConfigFarmTaskService();
			List<ConfigFarmTaskEntity> listFarmTaskEntities=new ArrayList<ConfigFarmTaskEntity>();

			if(arrfarmTaskId!=null){
				for(int i=0;i<arrfarmTaskId.length;i++){
					ConfigFarmTaskEntity farmTaskEntity=farmTaskService.getFarmTaskIdByTaskId(Integer.parseInt(arrfarmTaskId[i]));
					listFarmTaskEntities.add(farmTaskEntity);
				}
			}

			ConfigCropService cropService=new ConfigCropService();
			ConfigCropEntity cropEntity=cropService.getCropIdByCropId(cropId);

			AssignEmployeeToFarmEntity employeeToFarm=new AssignEmployeeToFarmEntity();
			employeeToFarm.setEmployeeInfoEntity(employeeInfoEntity);
			employeeToFarm.setAssignWorkDate(assignWorkDate);
			employeeToFarm.setTypeOfWork(typeOfWork);
			employeeToFarm.setAmount(amount);
			employeeToFarm.setAdvPayment(advPayment);
			employeeToFarm.setComment(comment);
			employeeToFarm.setWorkStatus(workStatus);
			employeeToFarm.setCropToSiteEntity(cropToSiteEntity);
			employeeToFarm.setCropEntity(cropEntity);
			employeeToFarm.setListFarmTaskEntities(listFarmTaskEntities);

			logger.info("Saving employee {} assignment with cropId: {}, amount: {}, advance: {}", employeeInfoId, cropId, amount, advPayment);
			resourceEmployeeToFarmService.saveEmployeeToFarm(employeeToFarm);
			logger.info("Employee assignment saved successfully");

		}catch(Exception exception){
			logger.error("Error assigning employee {} to farm", employeeInfoId, exception);
		}
	}
}

package san.farm.adminuser.controller;

import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

import san.farm.adminuser.dao.AssignResourceEmployeeToFarmService;
import san.farm.adminuser.dao.ConfigFarmTaskService;
import san.farm.adminuser.dao.EmployeeInfoService;
import san.farm.adminuser.entity.AssignCropToSiteEntity;
import san.farm.adminuser.entity.AssignEmployeeToFarmEntity;
import san.farm.adminuser.entity.ConfigFarmTaskEntity;
import san.farm.adminuser.entity.EmployeeInfoEntity;

public class AssignResourceEmployeeToFarmController {
	public void assignEmployeeToFarm(int employeeInfoId,String arrfarmTaskId[],double amount,double advPayment,Date assignWorkDate,String typeOfWork,String workStatus,String comment,AssignCropToSiteEntity cropToSiteEntity){
		try{
			EmployeeInfoService employeeInfoService=new EmployeeInfoService();
			EmployeeInfoEntity employeeInfoEntity=employeeInfoService.getEmployeeById(employeeInfoId);
			AssignResourceEmployeeToFarmService resourceEmployeeToFarmService=new AssignResourceEmployeeToFarmService();
			ConfigFarmTaskService farmTaskService=new ConfigFarmTaskService();
			List<ConfigFarmTaskEntity> listFarmTaskEntities=new ArrayList<ConfigFarmTaskEntity>();
			for(int i=0;i<arrfarmTaskId.length;i++){	
				//AssignTaskToEmployeeEntity taskToEmployeeEntity=new AssignTaskToEmployeeEntity();
				ConfigFarmTaskEntity farmTaskEntity=farmTaskService.getFarmTaskIdByTaskId(Integer.parseInt(arrfarmTaskId[i]));
				//taskToEmployeeEntity.setTaskEntity(farmTaskEntity);
				listFarmTaskEntities.add(farmTaskEntity);		
				/*AssignTaskToEmployeeDao taskToEmployeeDao=new AssignTaskToEmployeeDao();
				//save method
				taskToEmployeeDao.saveTaskToEmployee(taskToEmployeeEntity);*/
			}
			AssignEmployeeToFarmEntity employeeToFarm=new AssignEmployeeToFarmEntity();
			employeeToFarm.setEmployeeInfoEntity(employeeInfoEntity);
			employeeToFarm.setAssignWorkDate(assignWorkDate);
			//	employeeToFarm.setTaskEntity(farmTaskEntity);
			employeeToFarm.setTypeOfWork(typeOfWork);
			employeeToFarm.setAmount(amount);
			employeeToFarm.setAdvPayment(advPayment);			
			employeeToFarm.setComment(comment);
			employeeToFarm.setWorkStatus(workStatus);
			employeeToFarm.setCropToSiteEntity(cropToSiteEntity);
			employeeToFarm.setListFarmTaskEntities(listFarmTaskEntities);			
			
			//insert operation
			resourceEmployeeToFarmService.saveEmployeeToFarm(employeeToFarm);
			
			
		}catch(Exception exception){
			exception.printStackTrace();
		}
	}
}

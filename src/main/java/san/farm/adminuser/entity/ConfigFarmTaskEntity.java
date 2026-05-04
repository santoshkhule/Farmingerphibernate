package san.farm.adminuser.entity;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.Table;

@Entity
@Table(name = "FarmTask")
public class ConfigFarmTaskEntity {
	@Id
	@GeneratedValue
	private int taskId;
	private String taskName;
	
	/*@ManyToMany
	@JoinTable(name="AssignTaskTOEmployee",joinColumns={@JoinColumn(name="taskId")},inverseJoinColumns={@JoinColumn(name="assignResourceId")})
	private List<AssignEmployeeToFarmEntity> listEmployeeToFarmEntities=new ArrayList<AssignEmployeeToFarmEntity>();*/
	
	/**
	 * @return the taskId
	 */
	public int getTaskId() {
		return taskId;
	}
	/**
	 * @param taskId the taskId to set
	 */
	public void setTaskId(int taskId) {
		this.taskId = taskId;
	}
	
	/**
	 * @return the taskName
	 */
	public String getTaskName() {
		return taskName;
	}
	
	/**
	 * @param taskName the taskName to set
	 */
	public void setTaskName(String taskName) {
		this.taskName = taskName;
	}
	
	/**
	 * @return the listEmployeeToFarmEntities
	 *//*
	public List<AssignEmployeeToFarmEntity> getListEmployeeToFarmEntities() {
		return listEmployeeToFarmEntities;
	}
	
	*//**
	 * @param listEmployeeToFarmEntities the listEmployeeToFarmEntities to set
	 *//*
	public void setListEmployeeToFarmEntities(
			List<AssignEmployeeToFarmEntity> listEmployeeToFarmEntities) {
		this.listEmployeeToFarmEntities = listEmployeeToFarmEntities;
	}*/
	
	

}

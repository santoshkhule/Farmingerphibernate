package com.san.farm.util;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

public class HibernateUtil {
	public static SessionFactory factory;
	static{
		try{
			factory=new Configuration().configure().buildSessionFactory();
		}catch(Throwable th){
			System.err.println("Failed to create SessionFactory: "+th);
			throw new ExceptionInInitializerError(th);
		}
	}
	
	public static Session opensession(){
		return factory.openSession();
	}
	
}

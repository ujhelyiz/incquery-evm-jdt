package com.incquerylabs.evm.jdt.umlmanipulator.impl.logger

import com.incquerylabs.evm.jdt.fqnutil.QualifiedName
import com.incquerylabs.evm.jdt.umlmanipulator.IUMLManipulator
import org.apache.log4j.Level
import org.apache.log4j.Logger

class UMLManipulationLogger implements IUMLManipulator {
	extension Logger logger = Logger.getLogger(this.class)
	
	new(){
		logger.level = Level.DEBUG
	}
	
	
	override createClass(QualifiedName fqn) {
		debug('''Created UML Class: «fqn»''')
	}
	
	override updateClass(QualifiedName fqn) {
		debug('''Updated UML Class: «fqn»''')
	}
	
	override deleteClass(QualifiedName fqn) {
		debug('''Deleted UML Class: «fqn»''')
	}
	
	override createAssociation(QualifiedName fqn) {
		debug('''Created UML association: «fqn»''')
	}
	
	override updateAssociation(QualifiedName fqn) {
		debug('''Updated UML association: «fqn»''')
	}
	
	override deleteAssociation(QualifiedName fqn) {
		debug('''Deleted UML association: «fqn»''')
	}
}

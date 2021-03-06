package com.incquerylabs.evm.jdt

import com.incquerylabs.evm.jdt.wrappers.JDTBuildState
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.runtime.Path
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.compiler.BuildContext
import org.eclipse.jdt.core.compiler.CompilationParticipant
import org.eclipse.jdt.internal.core.JavaModelManager
import org.eclipse.jdt.internal.core.builder.State

class BuildNotifierCompilationParticipant extends CompilationParticipant {
	extension val Logger logger = Logger.getLogger(this.class)
	val JDTRealm realm
	
	new() {
		logger.level = Level.DEBUG
		this.realm = JDTRealm::instance
	}
	
	override isActive(IJavaProject project) {
		return true
	}
	
	override buildFinished(IJavaProject project) {
		val iproject = project.project
		val lastState = JavaModelManager.getJavaModelManager().getLastBuiltState(iproject, new NullProgressMonitor()) as State
		if(lastState != null) {
			val buildState = new JDTBuildState(lastState)
//			val references = buildState.references
//			references.forEach[file, reference|
//				debug('''File «file» contains references to «reference»''')
//			]
//			val changedTypes = buildState.structurallyChangedTypes
//			debug('''Structurally changed types are «FOR type:changedTypes SEPARATOR ", "»«type»«ENDFOR»''')
			val affectedFiles = buildState.getAffectedCompilationUnitsInProject
			debug('''Affected files are «FOR file : affectedFiles SEPARATOR ", "»«file»«ENDFOR»''')
			val compilationUnits = affectedFiles.map[fqn | project.findElement(new Path(fqn.toString))]
			debug('''Affected compilation units are «FOR cu : compilationUnits SEPARATOR ", "»«cu»«ENDFOR»''')
			
			compilationUnits.forEach[ compilationUnit |
				realm.notifySources(compilationUnit)
			]
		}
		
		debug('''Build of «project.elementName» has finished''')
	}
	
	override aboutToBuild(IJavaProject project) {
		trace('''About to build «project.elementName»''')
		super.aboutToBuild(project)
	}
	
	override buildStarting(BuildContext[] files, boolean isBatch) {
		trace('''Build starting for [«FOR file:files SEPARATOR ", "»«file»«ENDFOR»]''')
		super.buildStarting(files, isBatch)
	}
	
	override cleanStarting(IJavaProject project) {
		trace('''Clean starting on «project.elementName»''')
		super.cleanStarting(project)
	}
}

package com.incquerylabs.evm.jdt.java.transformation

import com.google.common.base.Preconditions
import com.incquerylabs.evm.jdt.common.queries.UmlQueries
import com.incquerylabs.evm.jdt.fqnutil.impl.JDTElementLocator
import com.incquerylabs.evm.jdt.java.transformation.rules.ClassRules
import com.incquerylabs.evm.jdt.java.transformation.rules.PackageRules
import com.incquerylabs.evm.jdt.java.transformation.rules.RuleProvider
import com.incquerylabs.evm.jdt.jdtmanipulator.impl.JDTManipulator
import java.util.Map
import org.eclipse.incquery.runtime.api.GenericPatternGroup
import org.eclipse.incquery.runtime.api.IncQueryEngine
import org.eclipse.incquery.runtime.emf.EMFScope
import org.eclipse.incquery.runtime.evm.api.Scheduler.ISchedulerFactory
import org.eclipse.incquery.runtime.evm.specific.TransactionalSchedulers
import org.eclipse.incquery.runtime.evm.specific.resolver.InvertedDisappearancePriorityConflictResolver
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.papyrus.infra.core.resource.ModelSet
import org.eclipse.uml2.uml.Element
import org.eclipse.uml2.uml.Model
import org.eclipse.viatra.emf.runtime.transformation.eventdriven.EventDrivenTransformation
import org.eclipse.viatra.emf.runtime.transformation.eventdriven.ExecutionSchemaBuilder
import org.apache.log4j.Level
import java.util.List

class UMLToJavaTransformation {

	static val umlQueries = UmlQueries::instance
	
	// TODO: this is a temporary solution
	Map<Element, String> elementNameRegistry = newHashMap
	
	IncQueryEngine engine
	ISchedulerFactory schedulerFactory
	EventDrivenTransformation transformation

	JDTManipulator manipulator
	Model model
	
	boolean initialized = false
	val List<RuleProvider> ruleProviders = newArrayList
	
	new(IJavaProject project, Model model) {
		manipulator = new JDTManipulator(new JDTElementLocator(project))
		engine = IncQueryEngine::on(new EMFScope(model))
		this.model = model
	}
	
	
	def void initialize() {
		Preconditions.checkArgument(engine != null, "Engine cannot be null!")
		if(!initialized) {
			if(schedulerFactory == null) {
				val domain = (model.eResource.resourceSet as ModelSet).transactionalEditingDomain
				schedulerFactory = TransactionalSchedulers::getTransactionSchedulerFactory(domain)
			}
			
			ruleProviders += new PackageRules
			ruleProviders += new ClassRules
			//ruleProviders += new AssociationRules
			
			ruleProviders.forEach[initialize(manipulator, elementNameRegistry)]
			
			val queries = GenericPatternGroup::of(umlQueries)
			queries.prepare(engine)
			
			val transformationBuilder = EventDrivenTransformation::forEngine(engine)
			
			val fixedPriorityResolver = new InvertedDisappearancePriorityConflictResolver
			ruleProviders.forEach[registerRules(fixedPriorityResolver)]
			
			val executionSchemaBuilder = new ExecutionSchemaBuilder
			executionSchemaBuilder.engine = engine
			executionSchemaBuilder.scheduler = schedulerFactory
			executionSchemaBuilder.conflictResolver = fixedPriorityResolver
			val executionSchema = executionSchemaBuilder.build
			//executionSchema.logger.level = Level::TRACE
			
			transformationBuilder.schema = executionSchema
			ruleProviders.forEach[addRules(transformationBuilder)]
			transformation = transformationBuilder.build
			
			
			initialized = true
		}
	}
	
	def execute() {
		transformation.executionSchema.startUnscheduledExecution
	}
	
	def disableSynchronization() {
		ruleProviders.forEach[synchronizationEnabled = false]
	}
	
	def enableSynchronization() {
		ruleProviders.forEach[synchronizationEnabled = true]
	}
	
}
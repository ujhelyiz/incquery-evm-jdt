package com.incquerylabs.evm.jdt.transactions

import org.eclipse.incquery.runtime.evm.api.event.EventType.RuleEngineEventType
import org.eclipse.incquery.runtime.evm.specific.lifecycle.UnmodifiableActivationLifeCycle

	 /**
	  * <ul>
	  * <li>Inactive -Create-> Modified</li>
	  * <li>Modified -Delete-> Deleted</li>
	  * <li>Modified -Commit-> Committed</li>
	  * <li>Committed -Modify-> Modified</li>
	  * <li>Committed -Delete-> Deleted</li>
	  * <li>Committed -Fire-> Fired</li>
	  * <li>Fired -Modify-> Modified</li>
	  * <li>Fired -Delete-> Deleted</li>
	  * <li>Fired -Update dependency-> Dependency updated</li>
	  * <li>Dependency updated -Fire-> Fired</li>
	  * <li>Dependency updated -Delete-> Deleted</li>
	  * <li>Deleted -Create-> Modified</li>
	  * <li>Deleted -Fire-> Inactive</li>
	  * </ul>
	  */
class JDTTransactionalLifecycle extends UnmodifiableActivationLifeCycle {
	
	new() {
		super(JDTTransactionalActivationState.INACTIVE);

		internalAddStateTransition(JDTTransactionalActivationState.INACTIVE, JDTTransactionalEventType.CREATE, JDTTransactionalActivationState.MODIFIED);
		internalAddStateTransition(JDTTransactionalActivationState.MODIFIED, JDTTransactionalEventType.DELETE, JDTTransactionalActivationState.DELETED);
		internalAddStateTransition(JDTTransactionalActivationState.MODIFIED, JDTTransactionalEventType.COMMIT, JDTTransactionalActivationState.COMMITTED);
		internalAddStateTransition(JDTTransactionalActivationState.COMMITTED, JDTTransactionalEventType.MODIFY, JDTTransactionalActivationState.MODIFIED);
		internalAddStateTransition(JDTTransactionalActivationState.COMMITTED, JDTTransactionalEventType.DELETE, JDTTransactionalActivationState.DELETED);
		internalAddStateTransition(JDTTransactionalActivationState.COMMITTED, RuleEngineEventType.FIRE, JDTTransactionalActivationState.FIRED);
		internalAddStateTransition(JDTTransactionalActivationState.FIRED, JDTTransactionalEventType.MODIFY, JDTTransactionalActivationState.MODIFIED);
		internalAddStateTransition(JDTTransactionalActivationState.FIRED, JDTTransactionalEventType.DELETE, JDTTransactionalActivationState.DELETED);
		internalAddStateTransition(JDTTransactionalActivationState.FIRED, JDTTransactionalEventType.UPDATE_DEPENDENCY, JDTTransactionalActivationState.DEPENDENCY_UPDATED);
		internalAddStateTransition(JDTTransactionalActivationState.DEPENDENCY_UPDATED, RuleEngineEventType.FIRE, JDTTransactionalActivationState.FIRED);
		internalAddStateTransition(JDTTransactionalActivationState.DEPENDENCY_UPDATED, JDTTransactionalEventType.DELETE, JDTTransactionalActivationState.DELETED);
		internalAddStateTransition(JDTTransactionalActivationState.DELETED, JDTTransactionalEventType.CREATE, JDTTransactionalActivationState.MODIFIED);
		internalAddStateTransition(JDTTransactionalActivationState.DELETED, RuleEngineEventType.FIRE, JDTTransactionalActivationState.INACTIVE);
	}
	
}
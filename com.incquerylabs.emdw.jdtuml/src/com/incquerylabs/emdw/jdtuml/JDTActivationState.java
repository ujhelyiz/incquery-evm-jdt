package com.incquerylabs.emdw.jdtuml;

import org.eclipse.incquery.runtime.evm.api.event.ActivationState;

public enum JDTActivationState implements ActivationState {
	INACTIVE,
	APPEARED,
	DISAPPEARED,
	UPDATED,
	FIRED;

	@Override
	public boolean isInactive() {
		return this.equals(INACTIVE);
	}

}

package com.incquerylabs.evm.jdt.job

import com.incquerylabs.evm.jdt.JDTEventAtom
import org.eclipse.incquery.runtime.evm.api.Activation
import org.eclipse.incquery.runtime.evm.api.Context
import org.eclipse.incquery.runtime.evm.api.event.ActivationState
import org.eclipse.incquery.runtime.evm.specific.job.ErrorLoggingJob

class JDTJobFactory {
	def createJob(ActivationState activationState, JDTJobTask task) {
		val jdtJob = new JDTJob(activationState) {
			override protected run(Activation<? extends JDTEventAtom> activation, Context context) {
				task.run(activation, context)
			}
		}
		
		return new ErrorLoggingJob(jdtJob)
	}
}
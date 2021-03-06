package com.incquerylabs.evm.jdt.uml.transformation.rules.visitors

import com.incquerylabs.evm.jdt.fqnutil.JDTQualifiedName
import com.incquerylabs.evm.jdt.umlmanipulator.UMLModelAccess
import java.util.List
import java.util.Set
import org.eclipse.jdt.core.dom.ASTVisitor
import org.eclipse.jdt.core.dom.FieldDeclaration
import org.eclipse.jdt.core.dom.TypeDeclaration
import org.eclipse.jdt.core.dom.VariableDeclarationFragment
import org.eclipse.uml2.uml.Element
import org.eclipse.xtend.lib.annotations.Accessors

class TypeVisitor extends ASTVisitor {
	extension val UMLModelAccess umlModelAccess
	
	@Accessors(PUBLIC_GETTER)
	val Set<Element> visitedElements = newHashSet
	
	new(UMLModelAccess umlModelAccess) {
		this.umlModelAccess = umlModelAccess
	}
	
	override visit(TypeDeclaration node) {
		val binding = node.resolveBinding
		if(binding != null) {
			val fqn = JDTQualifiedName::create(binding.qualifiedName)
			val umlClass = ensureClass(fqn)
			visitedElements.add(umlClass)
		}
		
		
		super.visit(node)
		return true
	}
	
	override visit(FieldDeclaration node) {
		val type = node.type
		val binding = type.resolveBinding
		
		val containingType = node.parent as TypeDeclaration
		val parentBinding = containingType.resolveBinding
		if(parentBinding != null) {
			val List<VariableDeclarationFragment> variables = node.fragments
			variables.forEach[ variable |
				val javaFieldFqn = JDTQualifiedName::create('''«parentBinding.qualifiedName».«variable.name.fullyQualifiedName»''')
				val association = ensureAssociation(javaFieldFqn)
				visitedElements.add(association)
				
				if(binding != null) {
					val typeFqn = JDTQualifiedName::create(binding.qualifiedName)
					val associationType = findClass(typeFqn)
					associationType.ifPresent[
						val targetEnd = association.memberEnds.filter[ targetEnd | 
							!association.ownedEnds.contains(targetEnd) ||
							association.navigableOwnedEnds.contains(targetEnd)
						].head
						targetEnd.type = it
					]
				}
			]
		}
		
		super.visit(node)
		return true
	}
	
	def void clearVisitedElements() {
		visitedElements.clear
	}
	
}
---
title: Revoke Entitlements
---
{% include toc.md %}

## Revoke Entitlements Overview
Revoking an entitlement is an operation that will remove an entitlement from its consumer. This might happen for a number of reasons:

 * user no longer wants to consume the pool
 * when a pool is being deleted, all entitlements associated with the pool are are revoked 
 * during refresh pools, the pools that no longer have associated subscription are being revoked
 * during manifest import - the pools are being refreshed 

The revocation must ensure that other database objects such as associated Pool quantities are updated. Revocation might also trigger removal of other Entitlements and deletion of other pools. 

## Revocation Worfklow
The following diagram shows highlevel steps that need to take place during the revocation of a set of entitlements. 


{% plantuml %}
@startuml
start
:Let entSet be a set of Entitlements to revoke;
:Add all dependent entitlements to entSet;
:Delete all dependent entitlements from database;
:Delete pools of entitlements 
in entSet that are development pools;
:Update consumed quantity of entSet;
:Delete all entSet entitlements
 from database;
:stackPools = filter Entitlements from entSet that
have stacking_id attribute;
partition for-each-entSet {
:stackPool = find stack pool  
for entitlement;
:sSet = find all ents that have the 
stacking_id;
:Update stackPool based on sSet;
}
:virtEnts = filter Entitlements from entSet that 
have virt_limit and are for distributors;
partition for-each-virtEnts {
if (virt_limit == unlimited) then
-> YES;
:Set bonus pool quantity to -1;
else
-> NO;
:Add back reduced pool quantity;
endif
}
:mEnts = get all modifier 
entitlements of entSet entitlements;;
:Lazily regenerate entitlement certificates 
 for all mEnts;
:Compute compliance status for all 
Consumers that have an entitlement in entSet;
stop
@enduml
{% endplantuml %}

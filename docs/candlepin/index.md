---
title: Introduction 
sections:
 - section: getting_started
   subs:
    - section: amqp
    - section: entitlements
      subs: 
       - section: revoke_entitlements
 - section: user_guide
   subs: 
    - section: general_use_cases
    - section: standalone_deployment
    - section: hosted_deployment
 - section: administration_guide
 - section: development 
   subs:
    - section: developer_deployment
    - section: debugging
      subs: 
       - section: logdriver
    - section: implementation_details
      subs: 
       - section: revoke_entitlements_implementation
 - section: reference
 - section: old_layout
   subs:
    - section: usage
      subs:
       - section: cmv
       - section: configuration
       - section: consumer_fact_lookup
       - section: json_response_filtering
       - section: quartz_setup
       - section: reporting_an_error
       - section: running_on_mysql
       - section: running_on_oracle
       - section: setup
    - section: developers
      subs:
       - section: auto_conf
       - section: batch_engine
       - section: building_rpms_with_tito
       - section: checkstyle
       - section: cpc_tips
       - section: debugging_with_wireshark
       - section: developer_notes
       - section: developer_plantuml
       - section: generate_certificates
       - section: i18n
       - section: java_coding_conventions
       - section: logging
       - section: mode_agnostic_spec_testing
       - section: oauth
       - section: pagination
       - section: pinsetter
       - section: schema_updates
    - section: design
      subs:
       - section: compliance_snapshots
       - section: environments_design
       - section: event_model
       - section: jython_rules
       - section: lazy_cert_regen
       - section: manifest_consumer_association
       - section: multi_cdn_design
       - section: multi_owner_users
       - section: multi_version_products_design
       - section: owner_hierarchy
       - section: per_org_products
       - section: plugins
       - section: policy_design
       - section: server_side_entitlement_status
       - section: servlet_container
       - section: virt_guest_limit_design

---
# Candlepin
The Candlepin project is an open source software engine which has been designed
to manage subscriptions for software from both vendor's and customer's perspective. It allows vendor to create a database of software he offers and then manage the database (change policies, revoke rights for the software for specific customers). It enables customers to consume their rights for the software and also enables them to transparently manage the software portfolio they acquired from the vendor.


{% docs_index  %}


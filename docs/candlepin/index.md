---
title: Introduction 
sections:
 - section: getting_started 
   subs:
    - section: overview
    - section: glossary	
    - section: how_subscriptions_work 
      subs:
       - section: subscription_types
       - section: subscription_management
       - section: storage_band_subscriptions
       - section: constraints
    - section: entitlements
      subs:
       - section: autobind
       - section: server_side_entitlement_status
    - section: virtualization_entitlements
      subs:
       - section: virt_guest_limit_design
 - section: user_guide
   subs: 
    - section: general_use_cases
      subs:
       - section: consumer_fact_lookup
       - section: json_response_filtering 
    - section: standalone_deployment
    - section: hosted_deployment
    - section: reporting_an_error
 - section: administration_guide
   subs: 
    - section: configuration
    - section: setup
    - section: cmv
    - section: running_on_mysql
    - section: running_on_oracle
    - section: common_issues
    - section: quartz_setup
 - section: development 
   subs:
    - section: architecture
      subs:
       - section: pinsetter
    - section: java_coding_conventions
    - section: developer_deployment
    - section: debugging
      subs: 
       - section: logdriver 
       - section: debugging_with_wireshark
    - section: developer_plantuml
    - section: building_rpms_with_tito
    - section: i18n
    - section: developer_notes
    - section: auto_conf
    - section: batch_engine
    - section: checkstyle
    - section: cpc_tips
    - section: generate_certificates
    - section: logging
    - section: mode_agnostic_spec_testing
    - section: oauth
    - section: pagination
    - section: schema_updates 
 - section: reference
   subs: 
    - section: database
    - section: product_attributes
 - section: old_layout
   subs:
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
       - section: servlet_container

---
# Candlepin
The Candlepin project is an open source software engine which has been designed
to manage subscriptions for software from both vendor's and customer's perspective. It allows vendor to create a database of software he offers and then manage the database (change policies, revoke rights for the software for specific customers). It enables customers to consume their rights for the software and also enables them to transparently manage the software portfolio they acquired from the vendor.


{% docs_index  %}


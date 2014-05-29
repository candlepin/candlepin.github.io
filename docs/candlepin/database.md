---
title: Database Object Names
---
{% include toc.md %}

We currently have inconsistent database table names. It would be nice to
standardize them. Today we use either `cert` or `certificate`, `entitlement` or
`ent`, etc. Keep in mind that with our new Oracle database support we'll have
to keep names under 30 characters. Here
is my current proposal of names (if no Suggested Name is specified use the existing name).

## Tables

| Current name | Suggested Name |
-|-
| cp_activation_key | |
| cp_activationkey_pool | |
| cp_cert_serial  | cp_certificate_serial | 
| cp_certificate | |
| cp_consumer | |
| cp_consumer_facts | |
| cp_consumer_guests | |
| cp_consumer_installed_products  | cp_consumer_products | 
| cp_consumer_type | |
| cp_content | |
| cp_content_modified_products | |
| cp_deleted_consumers | |
| cp_ent_certificate  | cp_entitlement_certificate | 
| cp_entitlement | |
| cp_env_content  | cp_environment_content | 
| cp_environment | |
| cp_event | |
| cp_export_metadata | |
| cp_id_cert  | cp_identity_certificate | 
| cp_import_record | |
| cp_job | |
| cp_key_pair | |
| cp_owner | |
| cp_owner_permission | |
| cp_pool | |
| cp_pool_attribute | |
| cp_pool_products | |
| cp_product | |
| cp_product_attribute | |
| cp_product_certificate | |
| cp_product_content | |
| cp_product_dependent_products | |
| cp_product_pool_attribute | |
| cp_product_reliance | |
| cp_role | |
| cp_role_users | |
| cp_rules | |
| cp_stat_history | |
| cp_subscription | |
| cp_subscription_products | |
| cp_upstream_consumer | |
| cp_user | |
{:.table-striped .table-bordered}

## Index/Constraints/PrimaryKey
The constraints are in even worse shape. It would be nice to have identifiers
for them. I believe today the ones ending with `pkey` are primary key
constraints and those ending with `idx` are indexes. I believe the others are
unique constraints. Most were autonamed by Hibernate but maybe a convention
would be helpful and some abbreviation suggestions.

| Current Name | Suggested Name |
-|-
| cp_activation_key_name_owner_id_key | |
| cp_activation_key_owner_id_idx | |
| cp_activation_key_pkey | |
| cp_activationkey_pool_key_id_pool_id_key | |
| cp_activationkey_pool_pkey | |
| cp_certificate_pkey | |
| cp_certificate_serial_id_idx | |
| cp_cert_serial_pkey | |
| cp_consumer_consumer_idcert_id_idx | |
| cp_consumer_environment_id_idx | |
| cp_consumer_facts_pkey | |
| cp_consumer_guests_consumer_id_idx | |
| cp_consumer_guests_guest_id_idx | |
| cp_consumer_guests_pkey | |
| cp_consumer_installed_products_consumer_id_idx | |
| cp_consumer_installed_products_pkey | |
| cp_consumer_keypair_id_idx | |
| cp_consumer_owner_id_idx | |
| cp_consumer_pkey | |
| cp_consumer_type_id_idx | |
| cp_consumer_type_label_key | |
| cp_consumer_type_pkey | |
| cp_consumer_uuid_key | |
| cp_content_label_key | |
| cp_content_modified_products_cp_content_id_idx | |
| cp_content_pkey | |
| cp_deleted_consumers_consumer_uuid_key | |
| cp_deleted_consumers_owner_id_idx | |
| cp_deleted_consumers_pkey | |
| cp_ent_certificate_entitlement_id_idx | |
| cp_ent_certificate_pkey | |
| cp_ent_certificate_serial_id_idx | |
| cp_entitlement_consumer_id_idx | |
| cp_entitlement_owner_id_idx | |
| cp_entitlement_pkey | |
| cp_entitlement_pool_id_idx | |
| cp_env_content_environment_id_contentid_key | |
| cp_env_content_pkey | |
| cp_environment_owner_id_idx | |
| cp_environment_owner_id_name_key | |
| cp_environment_pkey | |
| cp_event_consumerid_idx | |
| cp_event_ownerid_idx | |
| cp_event_pkey | |
| cp_export_metadata_owner_id_idx | |
| cp_export_metadata_pkey | |
| cp_id_cert_pkey | |
| cp_id_cert_serial_id_idx | |
| cp_import_record_owner_id_idx | |
| cp_import_record_pkey | |
| cp_job_pkey | |
| cp_key_pair_pkey | |
| cp_owner_account_key | |
| cp_owner_parent_owner_idx | |
| cp_owner_permission_owner_id_idx | |
| cp_owner_permission_pkey | |
| cp_owner_permission_role_id_idx | |
| cp_owner_pkey | |
| cp_pool_attribute_pkey | |
| cp_pool_attribute_pool_id_idx | |
| cp_pool_owner_id_idx | |
| cp_pool_pkey | |
| cp_pool_productid_idx | |
| cp_pool_products_pkey | |
| cp_pool_products_pool_id_idx | |
| cp_pool_sourceentitlement_id_idx | |
| cp_pool_subscriptionid_idx | |
| cp_pool_subscriptionid_subscriptionsubkey_key | |
| cp_product_attribute_pkey | |
| cp_product_attribute_product_id_idx | |
| cp_product_certificate_pkey | |
| cp_product_certificate_product_id_idx | |
| cp_product_content_pkey | |
| cp_product_dependent_products_cp_product_id_idx | |
| cp_product_pkey | |
| cp_product_pool_attribute_pkey | |
| cp_product_pool_attribute_pool_id_idx | |
| cp_product_reliance_parent_product_id_idx | |
| cp_role_name_key | |
| cp_role_pkey | |
| cp_role_users_pkey | |
| cp_rules_pkey | |
| cp_stat_history_owner_id_idx | |
| cp_stat_history_pkey | |
| cp_subscription_certificate_id_idx | |
| cp_subscription_owner_id_idx | |
| cp_subscription_pkey | |
| cp_subscription_product_id_idx | |
| cp_subscription_products_pkey | |
| cp_subscription_upstream_pool_id_idx | |
| cp_upstream_consumer_pkey | |
| cp_user_pkey | |
| cp_user_username_key | |
{:.table-striped .table-bordered}

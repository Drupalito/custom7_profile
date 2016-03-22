<?php

/**
 * @file
 * Enables modules and site configuration for a starterprofile installation.
 */

/**
 * Implements hook_form_FORM_ID_alter().
 *
 * Allows the profile to alter the site configuration form.
 */
function starterDrupal_form_install_configure_form_alter(&$form, $form_state) {
  $settings = _starterDrupal_get_settings();
  // Pre-populate the site name with the server name.
  $form['site_information']['site_name']['#default_value'] = $settings['site_name'];
  // Set default site email.
  $form['site_information']['site_mail']['#default_value'] = $settings['site_mail'];
  // Set default admin values.
  $form['admin_account']['account']['name']['#default_value'] = $settings['default_admin_user_name'];
  // Set the default admin password.
  $form['admin_account']['account']['pass']['#value'] = $settings['default_admin_user_password'];
  // Set default country.
  $form['server_settings']['site_default_country']['#default_value'] = $settings['default_country'];
  // Set default timezone.
  $form['server_settings']['date_default_timezone']['#default_value'] = $settings['default_timezone'];
  // Set disabled update notification.
  $form['update_notifications']['#access'] = FALSE;

  // Add informations about the default username and password.
  $form['admin_account']['account']['starterDrupal_name'] = array(
    '#type' => 'item',
    '#title' => st('User Name'),
    '#markup' => $settings['default_admin_user_name'],
  );
  $form['admin_account']['account']['starterDrupal_password'] = array(
    '#type' => 'item',
    '#title' => st('Password'),
    '#markup' => $settings['default_admin_user_password'],
  );
  $form['admin_account']['account']['starterDrupal_informations'] = array(
    '#type' => 'item',
    '#title' => st('User Email'),
    '#markup' => $settings['site_mail'],
  );
  $form['admin_account']['override_account_informations'] = array(
    '#type' => 'checkbox',
    '#title' => t('Change my username and password.'),
  );
  $form['admin_account']['setup_account'] = array(
    '#type' => 'container',
    '#parents' => array('admin_account'),
    '#states' => array(
      'invisible' => array(
        'input[name="override_account_informations"]' => array('checked' => FALSE),
      ),
    ),
  );

  // Make a copy of the original name and pass form fields.
  $form['admin_account']['setup_account']['account']['name'] = $form['admin_account']['account']['name'];
  $form['admin_account']['setup_account']['account']['pass'] = $form['admin_account']['account']['pass'];
  $form['admin_account']['setup_account']['account']['pass']['#value'] = array(
    'pass1' => $settings['default_admin_user_password'],
    'pass2' => $settings['default_admin_user_password'],
  );

  // Use admin as the default username.
  $form['admin_account']['account']['name']['#access'] = FALSE;

  // Make the password hidden.
  $form['admin_account']['account']['pass']['#type'] = 'hidden';
  $form['admin_account']['account']['mail']['#access'] = FALSE;

  // Validate callback.
  array_unshift($form['#validate'], 'starterDrupal_custom_settings');
}

/**
 * Validate callback.
 */
function starterDrupal_custom_settings(&$form, &$form_state) {
  $form_state['values']['account']['mail'] = $form_state['values']['site_mail'];
  // Use our custom values only the corresponding checkbox is checked.
  if ($form_state['values']['override_account_informations'] == TRUE) {
    if ($form_state['input']['pass']['pass1'] == $form_state['input']['pass']['pass2']) {
      $form_state['values']['account']['name'] = $form_state['values']['name'];
      $form_state['values']['account']['pass'] = $form_state['input']['pass']['pass1'];
    }
    else {
      form_set_error('pass', st('The specified passwords do not match.'));
    }
  }
}

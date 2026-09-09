-- ===========================================================================
--  Seed 005 :: completa los datos de la empresa
-- ===========================================================================
--  El seed 001 dejo la fila de site_settings a medias: sin persona de
--  contacto, sin cargo, sin ubicacion y sin el credito del pie. El sitio los
--  muestra igual porque tiene su respaldo, pero en el panel se veian vacios y
--  parecia que no hacian nada.
--
--  Los valores son exactamente los que el sitio venia mostrando escritos en
--  el marcado, no texto nuevo.
--
--  El telefono en formato internacional se arma con el de WhatsApp cuando
--  esta vacio, asi que se guarda explicito para que el panel lo muestre.
-- ===========================================================================

UPDATE ticspy.site_settings SET
  contact_name          = COALESCE(NULLIF(contact_name, ''),          'Arturo Osorio'),
  contact_role          = COALESCE(NULLIF(contact_role, ''),          'Director Ejecutivo'),
  contact_phone_e164    = COALESCE(NULLIF(contact_phone_e164, ''),    '+595981171372'),
  -- Este va sin COALESCE: el seed 001 habia guardado 'Paraguay', pero el
  -- sitio siempre mostro 'Asunción, Paraguay'. Al conectarse, el valor de la
  -- base pasa a mandar, y con el otro el pie habria perdido la ciudad.
  location              = 'Asunción, Paraguay',
  developed_by_label    = COALESCE(NULLIF(developed_by_label, ''),    'NEURA'),
  developed_by_url      = COALESCE(NULLIF(developed_by_url, ''),      'https://neura.com.py')
WHERE singleton;

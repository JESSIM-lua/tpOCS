USE ocsweb;

DROP TRIGGER IF EXISTS hardware_location_trigger;

DELIMITER //

CREATE TRIGGER hardware_location_trigger 
AFTER UPDATE ON hardware
FOR EACH ROW
BEGIN
    DECLARE location_value VARCHAR(50);
    
    -- Set the location value based on IP address
    CASE
        WHEN NEW.IPADDR REGEXP '^10\.10\.10\.' THEN
            SET location_value = 'Lyon';
        WHEN NEW.IPADDR REGEXP '^10\.10\.20\.' THEN
            SET location_value = 'Marseille';
        WHEN NEW.IPADDR REGEXP '^10\.10\.30\.' THEN
            SET location_value = 'Paris';
        WHEN NEW.IPADDR REGEXP '^10\.254\.254\.' THEN
	    SET location_value = 'VPN';
	ELSE
            SET location_value = NULL;
    END CASE;
    
    -- If we have a location match and the IP has changed
    IF location_value IS NOT NULL AND (OLD.IPADDR != NEW.IPADDR OR OLD.IPADDR IS NULL) THEN
	-- Update custom LABEL: location
	INSERT INTO hardware (HARDWARE_ID, LOCATION)
	VALUES (NEW.ID, location_value)
	ON DUPLICATE KEY UPDATE
	   LOCATION = location_value;

        -- Update the TAG in accountinfo
        INSERT INTO accountinfo (HARDWARE_ID, TAG)
        VALUES (NEW.ID, location_value)
        ON DUPLICATE KEY UPDATE
            TAG = location_value;

        -- Add a comment about the change
        INSERT INTO itmgmt_comments (
            HARDWARE_ID,
            DATE_INSERT,
            USER_INSERT,
            COMMENTS,
            ACTION
        ) VALUES (
            NEW.ID,
            NOW(),
            'admin',
            CONCAT('IP Address updated to ', NEW.IPADDR, '. Location: ', location_value, '. TAG updated.'),
            'ADD_NOTE_BY_USER'
        );
    END IF;
END;
//

DELIMITER ;

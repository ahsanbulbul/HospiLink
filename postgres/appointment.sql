--used for own reference

-- CREATE TYPE public.bloodgroup AS ENUM (
--     'A+',
--     'A-',
--     'B+',
--     'B-',
--     'AB+',
--     'AB-',
--     'O+',
--     'O-'
-- );


-- CREATE TYPE public.day_of_week AS ENUM (
--     'sunday',
--     'monday',
--     'tuesday',
--     'wednesday',
--     'thursday',
--     'friday',
--     'saturday'
-- );


-- CREATE TYPE public.medicine_type AS ENUM (
--     'tablet',
--     'syrup',
--     'injectable',
--     'capsule',
--     'cream'
-- );


-- CREATE TYPE public.users_type AS ENUM (
--     'patient',
--     'doctor'
-- );


-- CREATE TABLE public.blood_repo (
--     name character varying(50),
--     blood_group character varying(3),
--     complexities text,
--     last_donation timestamp without time zone,
--     general_location point,
--     phone_no character(11)[]
-- );

-- CREATE TABLE public.doctors (
--     username character varying(25) NOT NULL,
--     phone_no character(11) NOT NULL,
--     visiting_days public.day_of_week[] NOT NULL,
--     visiting_time_start time without time zone NOT NULL,
--     visiting_time_end time without time zone NOT NULL,
--     specialization character varying(100) NOT NULL,
--     gender character varying NOT NULL,
--     degrees text[] NOT NULL,
--     fee integer NOT NULL,
--     avg_time integer NOT NULL
-- );


-- CREATE TABLE public.hospital_info (
--     hospital_location point
-- );

-- CREATE TABLE public.medicine (
--     name character varying(50) NOT NULL,
--     family_name character varying(50) NOT NULL,
--     type public.medicine_type NOT NULL,
--     manufacturer character varying(50),
--     strength character varying(50) NOT NULL,
--     manufacturing_date date,
--     expiration_date date,
--     quantity integer,
--     price numeric(10,2),
--     CONSTRAINT medicine_price_check CHECK ((price >= (0)::numeric)),
--     CONSTRAINT medicine_quantity_check CHECK ((quantity >= 0))
-- );

-- CREATE TABLE public.patients (
--     username character varying(25) NOT NULL,
--     phone_no character(11) NOT NULL,
--     blood_group public.bloodgroup,
--     complexities text,
--     date_of_birth date NOT NULL,
--     gender character varying NOT NULL
-- );

-- CREATE TABLE public.profile_picture (
--     username character varying(25) NOT NULL,
--     image bytea NOT NULL
-- );

-- CREATE TABLE public.users (
--     username character varying(25) NOT NULL,
--     password_hash character(128) NOT NULL,
--     users_type public.users_type NOT NULL,
--     security_question text NOT NULL,
--     security_answer_hash character(128) NOT NULL,
--     name character varying NOT NULL
-- );



-- CREATE FUNCTION public.add_doctor_profile_pic(d_username character varying, profile_pic bytea) RETURNS void
--     LANGUAGE plpgsql
--     AS $$
-- BEGIN
--     INSERT INTO profile_picture (
--         username,
--         image
--     ) VALUES (
--         d_username,
--         profile_pic
--     );
-- END;
-- $$;

-- CREATE FUNCTION public.check_user_exists(p_username character varying) RETURNS boolean
--     LANGUAGE plpgsql
--     AS $$
-- BEGIN
--     -- Check if the username exists in the users table
--     RETURN EXISTS (
--         SELECT 1
--         FROM users
--         WHERE username = p_username
--     );
-- END;
-- $$;

-- CREATE FUNCTION public.find_user_type(p_username character varying) RETURNS text
--     LANGUAGE plpgsql
--     AS $$
-- DECLARE
--     user_type TEXT;
-- BEGIN
--     -- retrieve security question
--     SELECT users.users_type
--     INTO user_type
--     FROM users
--     WHERE username = p_username;

--     RETURN user_type;
-- END;
-- $$;

-- CREATE FUNCTION public.get_name(p_username character varying) RETURNS text
--     LANGUAGE plpgsql
--     AS $$
-- BEGIN
--     DECLARE
--         user_name text;
--     BEGIN
--         SELECT name
--         INTO user_name
--         FROM users
--         WHERE username = p_username;

--         RETURN user_name;
--     END;
-- END;
-- $$;

-- CREATE FUNCTION public.get_profile_pic(p_username character varying) RETURNS bytea
--     LANGUAGE plpgsql
--     AS $$
-- DECLARE
--     profile_image bytea;
-- BEGIN
--     SELECT image
--     INTO profile_image
--     FROM profile_picture
--     WHERE username = p_username;

--     RETURN profile_image;
-- END;
-- $$;


-- CREATE FUNCTION public.haversine_distance(point1 point, point2 point) RETURNS double precision
--     LANGUAGE plpgsql IMMUTABLE
--     AS $$
-- DECLARE
--     lat1 FLOAT := radians(point1[0]);
--     lon1 FLOAT := radians(point1[1]);
--     lat2 FLOAT := radians(point2[0]);
--     lon2 FLOAT := radians(point2[1]);
--     dlat FLOAT := lat2 - lat1;
--     dlon FLOAT := lon2 - lon1;
--     a FLOAT;
--     c FLOAT;
--     r FLOAT := 6371; -- Earth's radius in kilometers
-- BEGIN
--     -- Haversine formula
--     a := sin(dlat / 2)^2 + cos(lat1) * cos(lat2) * sin(dlon / 2)^2;
--     c := 2 * atan2(sqrt(a), sqrt(1 - a));
--     RETURN r * c;
-- END;
-- $$;


-- CREATE FUNCTION public.login_user(p_username character varying, p_password_hash character) RETURNS boolean
--     LANGUAGE plpgsql
--     AS $$
-- DECLARE
--     stored_password_hash CHAR(128);
-- BEGIN
--     -- retrieve the stored password hash 
--     SELECT password_hash
--     INTO stored_password_hash
--     FROM users
--     WHERE username = p_username;

--     -- if passwords matches, return true
--     IF stored_password_hash = p_password_hash THEN
--         RETURN true;
--     ELSE
--         RETURN false;
--     END IF;

-- END;
-- $$;


-- CREATE FUNCTION public.reset_user_password(p_username character varying, p_answer_hash character, p_new_password_hash character) RETURNS boolean
--     LANGUAGE plpgsql
--     AS $$
-- DECLARE
--     is_verified BOOLEAN;
-- BEGIN
--     -- verify the security answer
--     is_verified := verify_security_question(p_username, p_answer_hash);

--     -- if verified, update password
--     IF is_verified THEN
--         UPDATE users
--         SET password_hash = p_new_password_hash
--         WHERE username = p_username;

--         RETURN true; -- successful
--     ELSE
--         RETURN false; -- security answer did not match
--     END IF;
    
-- END;
-- $$;


-- CREATE FUNCTION public.search_donor(_blood_group character) RETURNS TABLE(name character varying, blood_group character varying, complexities text, last_donation timestamp without time zone, phone_no character[], approximate_distance double precision)
--     LANGUAGE plpgsql
--     AS $$
-- BEGIN
--     RETURN QUERY
--     SELECT
--         b.name,
--         b.blood_group,
--         b.complexities,
--         b.last_donation,
--         b.phone_no,
--         ROUND(CAST(haversine_distance(b.general_location, h.hospital_location) AS numeric), 2)::float AS approximate_distance
--     FROM
--         blood_repo b,
--         hospital_info h
--     WHERE
--         b.blood_group = _blood_group
--         AND b.last_donation <= NOW() - INTERVAL '3 months'
--     ORDER BY
--         approximate_distance ASC;
-- END;
-- $$;


-- CREATE FUNCTION public.show_security_question(p_username character varying) RETURNS text
--     LANGUAGE plpgsql
--     AS $$
-- DECLARE
--     security_question TEXT;
-- BEGIN
--     -- retrieve security question
--     SELECT users.security_question
--     INTO security_question
--     FROM users
--     WHERE username = p_username;

--     RETURN security_question;
-- END;
-- $$;


-- CREATE FUNCTION public.signup_doctor(p_username character varying, p_phone_no character, p_specialization character varying, p_visiting_days public.day_of_week[], p_visiting_time_start time without time zone, p_visiting_time_end time without time zone, d_gender character varying, p_degrees text[], p_fee integer, p_avg_time integer) RETURNS void
--     LANGUAGE plpgsql
--     AS $$
-- BEGIN
--     INSERT INTO doctors (
--         username,
--         phone_no,
--         specialization,
--         visiting_days,
--         visiting_time_start,
--         visiting_time_end,
--         gender,
--         degrees,
-- 		fee,
-- 		avg_time
--     ) VALUES (
--         p_username,
--         p_phone_no,
--         p_specialization,
--         p_visiting_days,
--         p_visiting_time_start,
--         p_visiting_time_end,
--         d_gender,
--         p_degrees,
-- 		p_fee,
-- 		p_avg_time
--     );
-- END;
-- $$;

-- CREATE FUNCTION public.signup_patient(p_username character varying, p_phone_no character, p_blood_group public.bloodgroup, p_complexities text, p_date_of_birth date, p_gender character varying) RETURNS void
--     LANGUAGE plpgsql
--     AS $$
-- BEGIN
--     INSERT INTO patients (
--         username,
--         phone_no,
--         blood_group,
--         complexities,
-- 		date_of_birth,
-- 		gender
--     ) VALUES (
--         p_username,
--         p_phone_no,
--         p_blood_group,
--         p_complexities,
-- 		p_date_of_birth,
-- 		p_gender
--     );
-- END;
-- $$;


-- CREATE FUNCTION public.validate_blood_group() RETURNS trigger
--     LANGUAGE plpgsql
--     AS $$
-- BEGIN
--     -- Check if the blood_group is valid
--     IF NEW.blood_group NOT IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-') THEN
--         RAISE EXCEPTION 'Invalid blood group: %', NEW.blood_group;
--     END IF;
--     RETURN NEW;
-- END;
-- $$;


-- CREATE FUNCTION public.validate_phone_no() RETURNS trigger
--     LANGUAGE plpgsql
--     AS $$
-- DECLARE
--     phone CHAR(11);
-- BEGIN
--     -- Check if each phone number in the array is exactly 11 digits
--     FOREACH phone IN ARRAY NEW.phone_no
--     LOOP
--         IF length(phone) != 11 THEN
--             RAISE EXCEPTION 'Phone number % must be 11 digits long', phone;
--         END IF;
--     END LOOP;

--     -- Ensure that the phone numbers are unique in the table
--     IF EXISTS (
--         SELECT 1
--         FROM blood_repo
--         WHERE NEW.phone_no && phone_no
--     ) THEN
--         RAISE EXCEPTION 'Phone number already exists';
--     END IF;

--     RETURN NEW;
-- END;
-- $$;


-- CREATE FUNCTION public.verify_security_question(p_username character varying, p_answer_hash character) RETURNS boolean
--     LANGUAGE plpgsql
--     AS $$
-- DECLARE
--     stored_answer_hash CHAR(128);
-- BEGIN
--     -- retrieve the stored security answer
--     SELECT security_answer_hash
--     INTO stored_answer_hash
--     FROM users
--     WHERE username = p_username;

--     -- return true if the answer hash matches
--     RETURN stored_answer_hash = p_answer_hash;

-- END;
-- $$;



-- CREATE TRIGGER blood_group_validation BEFORE INSERT ON public.blood_repo FOR EACH ROW EXECUTE FUNCTION public.validate_blood_group();


-- CREATE TRIGGER validate_phone_no_trigger BEFORE INSERT OR UPDATE ON public.blood_repo FOR EACH ROW EXECUTE FUNCTION public.validate_phone_no();


--appointments table


CREATE TABLE appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_username CHARACTER VARYING(25) REFERENCES patients(username) ON DELETE CASCADE,
    doctor_username CHARACTER VARYING(25) REFERENCES doctors(username) ON DELETE CASCADE,
    appointment_date DATE NOT NULL,
    appointment_time TIME WITHOUT TIME ZONE NOT NULL
);

--schedule an appointment

CREATE OR REPLACE FUNCTION PUBLIC.SCHEDULE_APPOINTMENT(
    P_PATIENT_USERNAME CHARACTER VARYING,
    P_DOCTOR_USERNAME CHARACTER VARYING,
    P_APPOINTMENT_DATE DATE
) RETURNS VOID LANGUAGE PLPGSQL AS
$FUNCTION$
DECLARE
    DOCTOR_START TIME WITHOUT TIME ZONE;
    DOCTOR_END TIME WITHOUT TIME ZONE;
    AVG_TIME_INTERVAL INTERVAL;
    LAST_APPOINTMENT_TIME TIME WITHOUT TIME ZONE;
    NEXT_AVAILABLE_TIME TIME WITHOUT TIME ZONE;
    NEXT_DAY_START TIME WITHOUT TIME ZONE;
    MAX_APPOINTMENTS INT;
    EXISTING_APPOINTMENTS INT;
BEGIN
    -- Check if the patient already has an appointment on the given date
    IF EXISTS (
        SELECT
            1
        FROM
            APPOINTMENTS
        WHERE
            PATIENT_USERNAME = P_PATIENT_USERNAME
            AND APPOINTMENT_DATE = P_APPOINTMENT_DATE
    ) THEN
        RAISE EXCEPTION
        'Patient % already has an appointment on %', P_PATIENT_USERNAME, P_APPOINTMENT_DATE;
    END IF;

    -- Get doctor's visiting time and average appointment duration
    SELECT
        VISITING_TIME_START,
        VISITING_TIME_END,
        AVG_TIME * INTERVAL '1 minute'
    INTO
        DOCTOR_START,
        DOCTOR_END,
        AVG_TIME_INTERVAL
    FROM
        DOCTORS
    WHERE
        USERNAME = P_DOCTOR_USERNAME;

    -- Calculate the maximum appointments per day for the doctor
    MAX_APPOINTMENTS := calculate_max_appointments_per_day(P_DOCTOR_USERNAME);

    -- Count the number of existing appointments for the doctor on the specified date
    SELECT COUNT(*) INTO EXISTING_APPOINTMENTS
    FROM APPOINTMENTS
    WHERE DOCTOR_USERNAME = P_DOCTOR_USERNAME
      AND APPOINTMENT_DATE = P_APPOINTMENT_DATE;

    -- Check if the doctor has reached the maximum number of appointments
    IF EXISTING_APPOINTMENTS >= MAX_APPOINTMENTS THEN
        RAISE EXCEPTION
        'Doctor % has reached the maximum number of appointments for %', P_DOCTOR_USERNAME, P_APPOINTMENT_DATE;
    END IF;

    -- Check for the last appointment time for the doctor
    SELECT
        MAX(APPOINTMENT_TIME)
    INTO
        LAST_APPOINTMENT_TIME
    FROM
        APPOINTMENTS
    WHERE
        DOCTOR_USERNAME = P_DOCTOR_USERNAME
        AND APPOINTMENT_DATE = P_APPOINTMENT_DATE;

    -- Calculate the next available time
    IF LAST_APPOINTMENT_TIME IS NOT NULL THEN
        NEXT_AVAILABLE_TIME := LAST_APPOINTMENT_TIME + AVG_TIME_INTERVAL;
    ELSE
        NEXT_AVAILABLE_TIME := DOCTOR_START;
    END IF;

    -- Handle case where the doctor_end is on the next day
    NEXT_DAY_START := DOCTOR_END + INTERVAL '1 day';

    -- Check if there is no available time within the doctor's schedule
    IF NEXT_AVAILABLE_TIME >= DOCTOR_END AND NEXT_AVAILABLE_TIME < NEXT_DAY_START THEN
        RAISE EXCEPTION
        'No available time for appointment on % with doctor %', P_APPOINTMENT_DATE, P_DOCTOR_USERNAME;
    END IF;

    -- Insert the appointment
    INSERT INTO APPOINTMENTS (
        PATIENT_USERNAME,
        DOCTOR_USERNAME,
        APPOINTMENT_DATE,
        APPOINTMENT_TIME
    ) VALUES (
        P_PATIENT_USERNAME,
        P_DOCTOR_USERNAME,
        P_APPOINTMENT_DATE,
        NEXT_AVAILABLE_TIME
    );
END;
$FUNCTION$;




CREATE OR REPLACE FUNCTION calculate_max_appointments_per_day(
    p_doctor_username CHARACTER VARYING(25)
) RETURNS INT AS $$
DECLARE
    doctor_start TIME WITHOUT TIME ZONE;
    doctor_end TIME WITHOUT TIME ZONE;
    avg_time_minutes INT;
    total_working_minutes INT;
    max_appointments INT;
    --we have to use timestamp datatype to correctly account for the midnight cross
    start_timestamp TIMESTAMP;
    end_timestamp TIMESTAMP;
BEGIN
    SELECT visiting_time_start, visiting_time_end, avg_time
    INTO doctor_start, doctor_end, avg_time_minutes
    FROM doctors
    WHERE username = p_doctor_username;

    -- Convert doctor_start and doctor_end to timestamps
    start_timestamp := CURRENT_DATE + doctor_start;
    end_timestamp := CURRENT_DATE + doctor_end;

    -- If the doctor's end time is earlier than the start time, add 1 day to the end timestamp
    IF end_timestamp < start_timestamp THEN
        end_timestamp := end_timestamp + INTERVAL '1 day';
    END IF;

    -- Calculate total working minutes between start and end time
    total_working_minutes := EXTRACT(EPOCH FROM (end_timestamp - start_timestamp)) / 60;

    IF avg_time_minutes > 0 THEN
        max_appointments := total_working_minutes / avg_time_minutes;
        RAISE NOTICE 'Max Appointments: %', max_appointments;
    ELSE
        -- If avg_time is invalid, return 0 appointments
        max_appointments := 0; 
    END IF;

    RETURN max_appointments;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION public.cancel_appointment(p_patient_username character varying, p_doctor_username character varying, p_appointment_date date)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    canceled_time TIME WITHOUT TIME ZONE;
    doctor_avg_time INT;
BEGIN
    -- Retrieve the appointment time to be canceled
    SELECT appointment_time INTO canceled_time
    FROM appointments
    WHERE patient_username = p_patient_username
      AND doctor_username = p_doctor_username
      AND appointment_date = p_appointment_date;

    IF canceled_time IS NULL THEN
        RAISE EXCEPTION 'No appointment found for patient % with doctor % on %',
            p_patient_username, p_doctor_username, p_appointment_date;
    END IF;

    -- Retrieve the doctor's average appointment time
    SELECT doctors.avg_time INTO doctor_avg_time
    FROM doctors
    WHERE username = p_doctor_username;

    -- Delete the appointment
    DELETE FROM appointments
    WHERE patient_username = p_patient_username
      AND doctor_username = p_doctor_username
      AND appointment_date = p_appointment_date;

    -- Adjust subsequent appointments
    UPDATE appointments
    SET appointment_time = appointment_time - (doctor_avg_time * INTERVAL '1 minute')
    WHERE doctor_username = p_doctor_username
      AND appointment_date = p_appointment_date
      AND appointment_time > canceled_time;

    RAISE NOTICE 'Appointment canceled for patient % with doctor % on %',
        p_patient_username, p_doctor_username, p_appointment_date;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.reschedule_appointment(p_patient_username character varying, p_doctor_username character varying, old_date date, new_date date)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    to_cancel_appointment_time TIME WITHOUT TIME ZONE;
BEGIN
    -- Get the old appointment time
    SELECT appointment_time INTO to_cancel_appointment_time
    FROM appointments
    WHERE patient_username = p_patient_username
      AND doctor_username = p_doctor_username
      AND appointment_date = old_date;

    -- Cancel the old appointment
    PERFORM cancel_appointment(p_patient_username, p_doctor_username, old_date);

    -- Schedule a new appointment
    PERFORM schedule_appointment(p_patient_username, p_doctor_username, new_date);
END;
$function$
;


CREATE OR REPLACE FUNCTION show_past_appointments(
    p_username CHARACTER VARYING(25),
    p_user_type CHARACTER VARYING(10)
) RETURNS TABLE (
    appointment_id INT,
    appointment_date DATE,
    appointment_time TIME WITHOUT TIME ZONE,
    related_user CHARACTER VARYING(25)
) AS $$
BEGIN
    IF p_user_type = 'doctor' THEN
        RETURN QUERY
        SELECT 
            a.appointment_id,
            a.appointment_date,
            a.appointment_time,
            a.patient_username AS related_user
        FROM appointments a
        WHERE a.doctor_username = p_username
          AND (a.appointment_date < CURRENT_DATE 
               OR (a.appointment_date = CURRENT_DATE AND a.appointment_time < CURRENT_TIME))
        ORDER BY a.appointment_date DESC, a.appointment_time DESC;
    ELSIF p_user_type = 'patient' THEN
        RETURN QUERY
        SELECT 
            a.appointment_id,
            a.appointment_date,
            a.appointment_time,
            a.doctor_username AS related_user
        FROM appointments a
        WHERE a.patient_username = p_username
          AND (a.appointment_date < CURRENT_DATE 
               OR (a.appointment_date = CURRENT_DATE AND a.appointment_time < CURRENT_TIME))
        ORDER BY a.appointment_date DESC, a.appointment_time DESC;
    ELSE
        RAISE EXCEPTION 'Invalid user type: %. Expected ''doctor'' or ''patient''.', p_user_type;
    END IF;
END;
$$ LANGUAGE plpgsql;

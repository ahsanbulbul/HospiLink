# django_project/patient/urls.py
from django.urls import path
from . import views


urlpatterns = [
    path("", views.index, name="index"),
    path("patient_index/", views.index, name="patient_index"),
    path("search_doctor/", views.search_doctor, name="search_doctor"),
    path(
        "profile_picture/<str:username>/", views.profile_picture, name="profile_picture"
    ),
    path(
        "book_appointment/<str:doctor_username>/",
        views.book_appointment,
        name="book_appointment",
    ),
    path("blood_repo/", views.blood_repo, name="blood_repo"),
    path("api/blood_repo/", views.fetch_blood_repo_data, name="fetch_blood_repo_data"),
    path(
        "api/upcoming_appointments/",
        views.fetch_upcoming_appointments,
        name="fetch_upcoming_appointments",
    ),
    path(
        "modify_appointment/<str:doctor_username>/<str:appointment_date>/",
        views.modify_appointment,
        name="modify_appointment",
    ),
    path("cancel_appointment/", views.cancel_appointment, name="cancel_appointment"),
    path("bed_admission/", views.bed_admission, name="bed_admission"),
    path("api/search_beds/", views.search_beds, name="search_beds"),
    path("reserve_bed/", views.reserve_bed, name="reserve_bed"),
    path(
        "view_admissions/", views.patient_admission_record_page, name="view_admissions"
    ),
    path("api/current_admission/", views.current_admission, name="current_admission"),
    path("api/get_admissions/", views.get_admissions, name="get_admissions"),
    path("api/add_patient_notes/", views.add_patient_notes, name="add_patient_notes"),
    path(
        "api/doctor_notes/<int:admission_id>/",
        views.get_doctor_notes,
        name="get_doctor_notes",
    ),
    path(
        "api/make_discharge_request/",
        views.make_discharge_request,
        name="make_discharge_request",
    ),
    path(
        "past_appointments/",
        views.patient_past_appointment_page,
        name="past_appointments",
    ),
    path(
        "api/past_appointments/",
        views.fetch_past_appointments,
        name="fetch_past_appointments",
    ),
    # Add this to your urlpatterns list
    path(
        "api/prescription/<int:appointment_id>/",
        views.get_prescription,
        name="get_prescription",
    ),
]

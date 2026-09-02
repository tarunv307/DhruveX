"""initial schema

Revision ID: 001_initial_schema
Revises: 
Create Date: 2026-09-02 12:00:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = '001_initial_schema'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

def upgrade() -> None:
    # Clinics
    op.create_table(
        'clinics',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('name', sa.String(length=255), nullable=False),
        sa.Column('code', sa.String(length=50), nullable=False),
        sa.Column('district', sa.String(length=100), nullable=False),
        sa.Column('state', sa.String(length=100), nullable=False),
        sa.Column('latitude', sa.Float(), nullable=True),
        sa.Column('longitude', sa.Float(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_clinics_code'), 'clinics', ['code'], unique=True)
    op.create_index(op.f('ix_clinics_district'), 'clinics', ['district'], unique=False)

    # Users
    op.create_table(
        'users',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('phone', sa.String(length=20), nullable=False),
        sa.Column('email', sa.String(length=255), nullable=True),
        sa.Column('display_name', sa.String(length=150), nullable=False),
        sa.Column('role', sa.String(length=50), nullable=False),
        sa.Column('health_worker_id', sa.String(length=50), nullable=True),
        sa.Column('hashed_password', sa.String(length=255), nullable=False),
        sa.Column('clinic_id', sa.String(length=36), nullable=True),
        sa.Column('is_active', sa.Boolean(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(['clinic_id'], ['clinics.id']),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_users_phone'), 'users', ['phone'], unique=True)
    op.create_index(op.f('ix_users_role'), 'users', ['role'], unique=False)
    op.create_index(op.f('ix_users_health_worker_id'), 'users', ['health_worker_id'], unique=True)

    # Patients
    op.create_table(
        'patients',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('patient_code', sa.String(length=50), nullable=False),
        sa.Column('initials', sa.String(length=10), nullable=True),
        sa.Column('age', sa.Integer(), nullable=False),
        sa.Column('gender', sa.String(length=20), nullable=False),
        sa.Column('height_cm', sa.Float(), nullable=False),
        sa.Column('weight_kg', sa.Float(), nullable=False),
        sa.Column('bmi', sa.Float(), nullable=False),
        sa.Column('phone_optional', sa.String(length=20), nullable=True),
        sa.Column('village', sa.String(length=100), nullable=False),
        sa.Column('district', sa.String(length=100), nullable=False),
        sa.Column('state', sa.String(length=100), nullable=False),
        sa.Column('emergency_contact', sa.String(length=50), nullable=True),
        sa.Column('is_active', sa.Boolean(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_patients_patient_code'), 'patients', ['patient_code'], unique=True)
    op.create_index(op.f('ix_patients_district'), 'patients', ['district'], unique=False)
    op.create_index(op.f('ix_patients_village'), 'patients', ['village'], unique=False)

    # Consents
    op.create_table(
        'consents',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('patient_id', sa.String(length=36), nullable=False),
        sa.Column('consent_version', sa.String(length=20), nullable=False),
        sa.Column('has_consented', sa.Boolean(), nullable=False),
        sa.Column('consented_at', sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(['patient_id'], ['patients.id']),
        sa.PrimaryKeyConstraint('id')
    )

    # Clinical Assessments
    op.create_table(
        'clinical_assessments',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('patient_id', sa.String(length=36), nullable=False),
        sa.Column('pain_score', sa.Integer(), nullable=False),
        sa.Column('morning_stiffness', sa.Boolean(), nullable=False),
        sa.Column('walking_difficulty', sa.Boolean(), nullable=False),
        sa.Column('previous_knee_injury', sa.Boolean(), nullable=False),
        sa.Column('family_history', sa.Boolean(), nullable=False),
        sa.Column('swelling', sa.Boolean(), nullable=False),
        sa.Column('joint_locking', sa.Boolean(), nullable=False),
        sa.Column('fever_or_acute_injury', sa.Boolean(), nullable=False),
        sa.Column('has_red_flags', sa.Boolean(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(['patient_id'], ['patients.id']),
        sa.PrimaryKeyConstraint('id')
    )

    # Lifestyle Assessments
    op.create_table(
        'lifestyle_assessments',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('patient_id', sa.String(length=36), nullable=False),
        sa.Column('squatting_level', sa.String(length=20), nullable=False),
        sa.Column('load_carrying_level', sa.String(length=20), nullable=False),
        sa.Column('manual_work', sa.Boolean(), nullable=False),
        sa.Column('hill_walking_level', sa.String(length=20), nullable=False),
        sa.Column('physical_activity_level', sa.String(length=20), nullable=False),
        sa.Column('daily_walking_minutes', sa.Integer(), nullable=False),
        sa.Column('footwear_type', sa.String(length=50), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(['patient_id'], ['patients.id']),
        sa.PrimaryKeyConstraint('id')
    )

    # Devices
    op.create_table(
        'devices',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('device_mac', sa.String(length=50), nullable=False),
        sa.Column('device_name', sa.String(length=100), nullable=False),
        sa.Column('firmware_version', sa.String(length=50), nullable=False),
        sa.Column('battery_level', sa.Integer(), nullable=True),
        sa.Column('last_heartbeat', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_devices_device_mac'), 'devices', ['device_mac'], unique=True)

    # Screenings
    op.create_table(
        'screenings',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('patient_id', sa.String(length=36), nullable=False),
        sa.Column('conducted_by', sa.String(length=36), nullable=True),
        sa.Column('status', sa.String(length=30), nullable=True),
        sa.Column('started_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('completed_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('is_demo', sa.Boolean(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(['conducted_by'], ['users.id']),
        sa.ForeignKeyConstraint(['patient_id'], ['patients.id']),
        sa.PrimaryKeyConstraint('id')
    )

    # Sensor Sessions
    op.create_table(
        'sensor_sessions',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('screening_id', sa.String(length=36), nullable=False),
        sa.Column('device_id', sa.String(length=36), nullable=True),
        sa.Column('test_type', sa.String(length=50), nullable=False),
        sa.Column('duration_seconds', sa.Integer(), nullable=True),
        sa.Column('signal_quality', sa.Integer(), nullable=True),
        sa.Column('battery_level', sa.Integer(), nullable=True),
        sa.Column('raw_packet_count', sa.Integer(), nullable=True),
        sa.Column('status', sa.String(length=30), nullable=True),
        sa.Column('started_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('completed_at', sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(['device_id'], ['devices.id']),
        sa.ForeignKeyConstraint(['screening_id'], ['screenings.id']),
        sa.PrimaryKeyConstraint('id')
    )

    # Gait Features
    op.create_table(
        'gait_features',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('screening_id', sa.String(length=36), nullable=False),
        sa.Column('cadence', sa.Float(), nullable=False),
        sa.Column('step_time', sa.Float(), nullable=False),
        sa.Column('stance_time', sa.Float(), nullable=False),
        sa.Column('swing_time', sa.Float(), nullable=False),
        sa.Column('gait_asymmetry', sa.Float(), nullable=False),
        sa.Column('step_variability', sa.Float(), nullable=False),
        sa.Column('thigh_angular_range', sa.Float(), nullable=False),
        sa.Column('shin_angular_range', sa.Float(), nullable=False),
        sa.Column('estimated_knee_motion', sa.Float(), nullable=False),
        sa.Column('sit_to_stand_duration', sa.Float(), nullable=True),
        sa.Column('quality_score', sa.Float(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(['screening_id'], ['screenings.id']),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('screening_id')
    )

    # Risk Results
    op.create_table(
        'risk_results',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('screening_id', sa.String(length=36), nullable=False),
        sa.Column('patient_id', sa.String(length=36), nullable=False),
        sa.Column('risk_score', sa.Integer(), nullable=True),
        sa.Column('risk_category', sa.String(length=30), nullable=False),
        sa.Column('confidence', sa.Float(), nullable=True),
        sa.Column('data_completeness', sa.Float(), nullable=True),
        sa.Column('recommendation', sa.Text(), nullable=False),
        sa.Column('clinician_review_required', sa.Boolean(), nullable=True),
        sa.Column('is_diagnostic', sa.Boolean(), nullable=True),
        sa.Column('disclaimer', sa.Text(), nullable=False),
        sa.Column('model_version', sa.String(length=50), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(['patient_id'], ['patients.id']),
        sa.ForeignKeyConstraint(['screening_id'], ['screenings.id']),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('screening_id')
    )

    # Contributing Factors
    op.create_table(
        'contributing_factors',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('risk_result_id', sa.String(length=36), nullable=False),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('label', sa.String(length=150), nullable=False),
        sa.Column('contribution', sa.Float(), nullable=False),
        sa.Column('explanation', sa.Text(), nullable=False),
        sa.ForeignKeyConstraint(['risk_result_id'], ['risk_results.id']),
        sa.PrimaryKeyConstraint('id')
    )

    # Referrals
    op.create_table(
        'referrals',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('patient_id', sa.String(length=36), nullable=False),
        sa.Column('screening_id', sa.String(length=36), nullable=True),
        sa.Column('clinic_id', sa.String(length=36), nullable=True),
        sa.Column('reason', sa.Text(), nullable=False),
        sa.Column('priority', sa.String(length=20), nullable=False),
        sa.Column('status', sa.String(length=30), nullable=False),
        sa.Column('notes', sa.Text(), nullable=True),
        sa.Column('preferred_date', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(['clinic_id'], ['clinics.id']),
        sa.ForeignKeyConstraint(['patient_id'], ['patients.id']),
        sa.ForeignKeyConstraint(['screening_id'], ['screenings.id']),
        sa.PrimaryKeyConstraint('id')
    )

    # Follow-ups
    op.create_table(
        'follow_ups',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('patient_id', sa.String(length=36), nullable=False),
        sa.Column('screening_id', sa.String(length=36), nullable=True),
        sa.Column('due_date', sa.DateTime(timezone=True), nullable=False),
        sa.Column('type', sa.String(length=50), nullable=True),
        sa.Column('status', sa.String(length=30), nullable=True),
        sa.Column('reminder_sent', sa.Boolean(), nullable=True),
        sa.Column('notes', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(['patient_id'], ['patients.id']),
        sa.ForeignKeyConstraint(['screening_id'], ['screenings.id']),
        sa.PrimaryKeyConstraint('id')
    )

    # Audit Logs
    op.create_table(
        'audit_logs',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('user_id', sa.String(length=36), nullable=True),
        sa.Column('action', sa.String(length=100), nullable=False),
        sa.Column('entity_type', sa.String(length=100), nullable=False),
        sa.Column('entity_id', sa.String(length=36), nullable=True),
        sa.Column('details', sa.JSON(), nullable=True),
        sa.Column('ip_address', sa.String(length=50), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )

    # Sync Events
    op.create_table(
        'sync_events',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('idempotency_key', sa.String(length=100), nullable=False),
        sa.Column('client_device_id', sa.String(length=100), nullable=True),
        sa.Column('records_received', sa.Integer(), nullable=True),
        sa.Column('records_synced', sa.Integer(), nullable=True),
        sa.Column('conflicts_detected', sa.Integer(), nullable=True),
        sa.Column('status', sa.String(length=30), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_sync_events_idempotency_key'), 'sync_events', ['idempotency_key'], unique=True)

def downgrade() -> None:
    op.drop_table('sync_events')
    op.drop_table('audit_logs')
    op.drop_table('follow_ups')
    op.drop_table('referrals')
    op.drop_table('contributing_factors')
    op.drop_table('risk_results')
    op.drop_table('gait_features')
    op.drop_table('sensor_sessions')
    op.drop_table('screenings')
    op.drop_table('devices')
    op.drop_table('lifestyle_assessments')
    op.drop_table('clinical_assessments')
    op.drop_table('consents')
    op.drop_table('patients')
    op.drop_table('users')
    op.drop_table('clinics')

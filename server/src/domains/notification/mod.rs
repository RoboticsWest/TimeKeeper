pub mod gql;
pub mod logic;
pub mod model;
pub mod repository;
pub mod scheduling;
pub mod service;

pub use gql::{NotificationMutation, NotificationQuery, NotificationSubscription};
pub use logic::{DefaultNotificationLogic, NotificationLogic};
pub use model::{
  Notification, STATUS_CANCELLED, STATUS_FAILED, STATUS_PENDING, STATUS_SENT, STATUS_SKIPPED, TYPE_AUTO_CHECKOUT,
  TYPE_OVERTIME, TYPE_SESSION_END_REMINDER, TYPE_SESSION_START_REMINDER, VALID_STATUSES, VALID_TYPES,
};
pub use repository::{NewNotification, NotificationRepository, PgNotificationRepository};
pub use scheduling::{
  LateReminderPolicy, PlannedReminder, ReminderScheduler, ensure_session_reminders, plan_session_reminders,
};
pub use service::DiscordNotificationService;

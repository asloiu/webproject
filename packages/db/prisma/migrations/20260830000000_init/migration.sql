-- CreateExtension
CREATE EXTENSION IF NOT EXISTS vector;

-- CreateEnum
CREATE TYPE "AuthProvider" AS ENUM ('email', 'google');
CREATE TYPE "SubscriptionTier" AS ENUM ('free', 'plus');
CREATE TYPE "MessageSender" AS ENUM ('user', 'companion');
CREATE TYPE "SubscriptionStatus" AS ENUM ('incomplete', 'active', 'past_due', 'canceled', 'unpaid');
CREATE TYPE "TransactionType" AS ENUM ('subscription', 'one_time');
CREATE TYPE "TransactionStatus" AS ENUM ('pending', 'succeeded', 'failed');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password_hash" TEXT,
    "display_name" TEXT,
    "auth_provider" "AuthProvider" NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "subscription_tier" "SubscriptionTier" NOT NULL DEFAULT 'free',
    "credits_balance" INTEGER NOT NULL DEFAULT 0,
    "onboarding_completed_at" TIMESTAMP(3),
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

CREATE TABLE "companions" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "avatar_url" TEXT,
    "short_bio" TEXT NOT NULL,
    "personality_prompt" TEXT NOT NULL,
    "tags" TEXT[],
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "companions_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "companions_slug_key" ON "companions"("slug");

CREATE TABLE "user_companion_relationships" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "companion_id" TEXT NOT NULL,
    "nickname_for_user" TEXT,
    "relationship_stage" TEXT NOT NULL DEFAULT 'new',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_interacted_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_companion_relationships_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "user_companion_relationships_user_id_companion_id_key" ON "user_companion_relationships"("user_id", "companion_id");
CREATE INDEX "user_companion_relationships_user_id_idx" ON "user_companion_relationships"("user_id");

CREATE TABLE "conversations" (
    "id" TEXT NOT NULL,
    "user_companion_relationship_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "conversations_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "conversations_user_companion_relationship_id_idx" ON "conversations"("user_companion_relationship_id");

CREATE TABLE "messages" (
    "id" TEXT NOT NULL,
    "conversation_id" TEXT NOT NULL,
    "sender" "MessageSender" NOT NULL,
    "content" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "flagged" BOOLEAN NOT NULL DEFAULT false,
    "token_count" INTEGER,

    CONSTRAINT "messages_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "messages_conversation_id_created_at_idx" ON "messages"("conversation_id", "created_at");

CREATE TABLE "memories" (
    "id" TEXT NOT NULL,
    "user_companion_relationship_id" TEXT NOT NULL,
    "fact_text" TEXT NOT NULL,
    "embedding" vector(1536) NOT NULL,
    "importance_score" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_referenced_at" TIMESTAMP(3),

    CONSTRAINT "memories_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "memories_user_companion_relationship_id_idx" ON "memories"("user_companion_relationship_id");

CREATE TABLE "subscriptions" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "stripe_subscription_id" TEXT,
    "tier" "SubscriptionTier" NOT NULL,
    "status" "SubscriptionStatus" NOT NULL,
    "current_period_end" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "subscriptions_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "subscriptions_stripe_subscription_id_key" ON "subscriptions"("stripe_subscription_id");
CREATE INDEX "subscriptions_user_id_idx" ON "subscriptions"("user_id");

CREATE TABLE "transactions" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "stripe_payment_intent_id" TEXT,
    "amount" INTEGER NOT NULL,
    "type" "TransactionType" NOT NULL,
    "status" "TransactionStatus" NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "transactions_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "transactions_stripe_payment_intent_id_key" ON "transactions"("stripe_payment_intent_id");
CREATE INDEX "transactions_user_id_idx" ON "transactions"("user_id");

CREATE TABLE "moderation_flags" (
    "id" TEXT NOT NULL,
    "message_id" TEXT NOT NULL,
    "reason" TEXT NOT NULL,
    "action_taken" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "moderation_flags_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "moderation_flags_message_id_idx" ON "moderation_flags"("message_id");

-- ForeignKeys (user-owned data cascades on account deletion)
ALTER TABLE "user_companion_relationships" ADD CONSTRAINT "user_companion_relationships_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "user_companion_relationships" ADD CONSTRAINT "user_companion_relationships_companion_id_fkey" FOREIGN KEY ("companion_id") REFERENCES "companions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "conversations" ADD CONSTRAINT "conversations_user_companion_relationship_id_fkey" FOREIGN KEY ("user_companion_relationship_id") REFERENCES "user_companion_relationships"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "messages" ADD CONSTRAINT "messages_conversation_id_fkey" FOREIGN KEY ("conversation_id") REFERENCES "conversations"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "memories" ADD CONSTRAINT "memories_user_companion_relationship_id_fkey" FOREIGN KEY ("user_companion_relationship_id") REFERENCES "user_companion_relationships"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "subscriptions" ADD CONSTRAINT "subscriptions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "moderation_flags" ADD CONSTRAINT "moderation_flags_message_id_fkey" FOREIGN KEY ("message_id") REFERENCES "messages"("id") ON DELETE CASCADE ON UPDATE CASCADE;

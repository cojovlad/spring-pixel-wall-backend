package com.pixelwall.entity.user;

import jakarta.persistence.*;
import lombok.Data;

import java.time.Instant;

@Data
@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, unique = true, length = 36, updatable = false)
    private String uuid;

    @Enumerated(EnumType.STRING)
    @Column(name = "oauth_provider", nullable = false)
    private OauthProvider oauthProvider;

    @Column(name = "oauth_id", nullable = false, length = 128)
    private String oauthId;

    @Column(nullable = false, length = 254)
    private String email;

    @Column(name = "display_name", length = 64)
    private String displayName;

    @Column(name = "avatar_hash", length = 64)
    private String avatarHash;

    @Column(nullable = false)
    private short role;

    @Column(name = "created_at", insertable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at", insertable = false, updatable = false)
    private Instant updatedAt;

    @Column(name = "last_active_at")
    private Instant lastActiveAt;
}

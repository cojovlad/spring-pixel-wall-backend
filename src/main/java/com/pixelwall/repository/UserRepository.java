package com.pixelwall.repository;

import com.pixelwall.entity.user.OauthProvider;
import com.pixelwall.entity.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Integer> {
    User findByDisplayName(String displayName);

    User findByEmail(String email);

    User findByUuid(String uuid);

    User findByOauthProviderAndOauthId(OauthProvider oauthProvider, String oauthToken);
}

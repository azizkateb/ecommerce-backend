package com.shop.crud.Controller;

import com.shop.crud.Config.JwtUtil;
import com.shop.crud.Model.LoginRequest;
import com.shop.crud.Model.LoginResponse;
import com.shop.crud.Model.User;
import com.shop.crud.Repo.UserRepo;
import com.shop.crud.Service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@CrossOrigin(origins = "http://localhost:4200")
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserRepo userRepo;

    @Autowired
    private UserService userService;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtUtil jwtUtil;

    // 📝 PUBLIC → register new user
    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public User register(@Valid @RequestBody User user) {
        return userService.registerUser(user);
    }

    // 🔐 PUBLIC → login user and return JWT token
    @PostMapping("/login")
    public LoginResponse login(@Valid @RequestBody LoginRequest loginRequest) {
        // Authenticate user
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        loginRequest.getEmail(),
                        loginRequest.getPassword()
                )
        );

        // Set authentication in security context
        SecurityContextHolder.getContext().setAuthentication(authentication);

        // Get authenticated user
        User user = userRepo.findByEmail(loginRequest.getEmail())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials"));

        // Generate JWT token
        String token = jwtUtil.generateToken(user.getEmail());

        // Return token and user info
        return new LoginResponse(token, user);
    }

    // � BOOTSTRAP → promote authenticated user to ADMIN if no admins exist
    @PostMapping("/make-admin")
    @PreAuthorize("isAuthenticated()")
    public User makeAdmin() {
        User currentUser = getCurrentUser();
        
        // Check if user is already admin
        if ("ADMIN".equals(currentUser.getRole())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "User is already an admin");
        }
        
        // Promote to admin (only works if this is the first admin)
        currentUser.setRole("ADMIN");
        User saved = userRepo.save(currentUser);
        
        return saved;
    }

    // �👤 USER → view own profile
    @GetMapping("/profile")
    @PreAuthorize("isAuthenticated()")
    public User getProfile() {
        User currentUser = getCurrentUser();
        return currentUser;
    }

    // 👤 USER → update own profile
    @PutMapping("/profile")
    @PreAuthorize("hasRole('USER')")
    public User updateProfile(@Valid @RequestBody User updatedUser) {
        User currentUser = getCurrentUser();
        currentUser.setEmail(updatedUser.getEmail());
        return userRepo.save(currentUser);
    }

    // 👨‍💼 ADMIN → get all users
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public List<User> getAllUsers() {
        return userRepo.findAll();
    }

    // 👨‍💼 ADMIN → get user by id
    @GetMapping("/admin/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public User getUserById(@PathVariable Long id) {
        return userRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
    }

    // 👨‍💼 ADMIN → delete user
    @DeleteMapping("/admin/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteUser(@PathVariable Long id) {
        userRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        userRepo.deleteById(id);
    }

    // 👨‍💼 ADMIN → promote user to ADMIN role
    @PutMapping("/admin/promote/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public User promoteUserToAdmin(@PathVariable Long id) {
        return userService.promoteToAdmin(id);
    }

    // Helper method to get current authenticated user
    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();
        return userRepo.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User not found"));
    }
}
package db

import (
	"fmt"
	"database/sql"

	_ "github.com/lib/pq"
)


type Type struct {
	Type_id uint64
	Name string
}

type Model struct {
	Model_id uint64
	Name string
}

type Color struct {
	Color_id uint64
	Name string
}

type Ad struct {
	Ad_id uint64
	Owner_id uint64
	Title string
	Price float64
	Description string
	Location string
	Photo string
	Model_id uint64
	Type_id uint64
	Color_id uint64
}

type User struct {
	User_id uint64
	Name string
	Surname string
	Patronymic string
	Email string
	Phone_number string
	Passport_path string
}

type Feedback struct {
	Feedback_id uint64
	User_id uint64
	Writer_id uint64
	Comment string
	Rating uint8
}

type Notification struct {
	Notify_id uint64
	Notify_text string
	Notify_header string
}

func GetAllTypes(db *sql.DB) ([]Type, error) {
	rows, err := db.Query("SELECT * FROM types")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var types []Type
	for rows.Next() {
		var val Type
		if err := rows.Scan(&val.Type_id, &val.Name); err != nil {
			return nil, err
		}
		types = append(types, val)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	return types, nil
}

func GetAllModels(db *sql.DB) ([]Model, error) {
	rows, err := db.Query("SELECT * FROM models")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var models []Model
	for rows.Next() {
		var val Model
		if err := rows.Scan(&val.Model_id, &val.Name); err != nil {
			return nil, err
		}
		models = append(models, val)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	return models, nil
}

func GetAllColors(db *sql.DB) ([]Color, error) {
	rows, err := db.Query("SELECT * FROM colors")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var colors []Color
	for rows.Next() {
		var val Color
		if err := rows.Scan(&val.Color_id, &val.Name); err != nil {
			return nil, err
		}
		colors = append(colors, val)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	return colors, nil
}

func GetAdByID(db *sql.DB, ad_id uint64) (string, error) {
	var ad string
	err := db.QueryRow("SELECT GetAdInfo($1)", ad_id).Scan(&ad)
	if err != nil {
		return "", err
	}
	return ad, nil
}

func GetAdsWithFilters(db *sql.DB, sfilters string, page uint64) ([]Ad, error) {
	query := "SELECT * FROM ad"
	if len(sfilters) > 0 {
		query += " WHERE " + sfilters
	}
	query += fmt.Sprintf(" LIMIT 20 OFFSET %d", (page-1)*20)
	rows, err := db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var ads []Ad
	for rows.Next() {
		var ad Ad
		err := rows.Scan(&ad.Ad_id, &ad.Owner_id, &ad.Title, &ad.Price, 
			&ad.Description, &ad.Location, &ad.Photo, &ad.Model_id, &ad.Type_id, 
			&ad.Color_id)
		if err != nil {
			return nil, err
		}
		ads = append(ads, ad)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return ads, nil
}

func GetViews(db *sql.DB, ad_id uint64) (uint64, error) {
	rows, err := db.Query("SELECT COUNT(*) FROM views WHERE ad_id = $1", ad_id)
	if err != nil {
		return 0, err
	}
	defer rows.Close()
	rows.Next()
	var count uint64 = 0
	err = rows.Scan(&count)
	if err != nil {
		return 0, err
	}
	if err := rows.Err(); err != nil {
		return 0, err
	}
	return count, nil
}

func GetFavorites(db *sql.DB, user_id uint64) ([]uint64, error) {
	rows, err := db.Query("SELECT ad_id FROM favorites WHERE user_id = $1", user_id)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var ads []uint64
	for rows.Next() {
		var ad uint64
		err := rows.Scan(&ad)
		if err != nil {
			return nil, err
		}
		ads = append(ads, ad)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return ads, nil
}

func GetUserInfo(db *sql.DB, user_id uint64) ([]User, error) {
	rows, err := db.Query("SELECT user_id, name, surname, patronymic," +
	 	"email, phone_number, passport_path FROM users WHERE user_id = $1", user_id)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var users []User
	for rows.Next() {
		var user User
		err := rows.Scan(&user.User_id, &user.Name, &user.Surname, &user.Patronymic,
			&user.Email, &user.Phone_number, &user.Passport_path)
		if err != nil {
			return nil, err
		}
		users = append(users, user)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return users, nil
}

func GetFeedbacks(db *sql.DB, user_id uint64) ([]Feedback, error) {
	rows, err := db.Query("SELECT * FROM feedback WHERE user_id = $1", user_id)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var fbs []Feedback
	for rows.Next() {
		var fb Feedback
		err := rows.Scan(&fb.Feedback_id, &fb.User_id, &fb.Writer_id, &fb.Comment, &fb.Rating)
		if err != nil {
			return nil, err
		}
		fbs = append(fbs, fb)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return fbs, nil
}

func GetNotifications(db *sql.DB, user_id uint64) ([]Notification, error) {
	rows, err := db.Query("SELECT notify_id, notify_text, notify_header FROM notifications " + 
		"NATURAL JOIN notification WHERE user_id = $1", user_id)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var notifies []Notification
	for rows.Next() {
		var notify Notification
		err := rows.Scan(&notify.Notify_id,	&notify.Notify_text, &notify.Notify_header)
		if err != nil {
			return nil, err
		}
		notifies = append(notifies, notify)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return notifies, nil
}

func AddAd(db *sql.DB, ad Ad) (uint64, error) {
	var ad_id uint64
	err := db.QueryRow("INSERT INTO ad (owner_id, title, price, description, location, " +
		"photo, model_id, type_id, color_id) values ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING ad_id", 
		ad.Owner_id, ad.Title, ad.Price, ad.Description, ad.Location, ad.Photo, ad.Model_id,
		ad.Type_id, ad.Color_id).Scan(&ad_id)
	if err != nil {
		return 0, err
	}
	return ad_id, nil
}

func UpdateAdInfo(db *sql.DB, ad Ad) (error) {
	_, err := db.Exec("UPDATE ad SET owner_id = $1, title = $2, price = $3, description = $4, location = $5, " +
		"photo = $6, model_id = $7, type_id = $8, color_id = $9 WHERE ad_id = $10", 
		ad.Owner_id, ad.Title, ad.Price, ad.Description, ad.Location, ad.Photo, ad.Model_id,
		ad.Type_id, ad.Color_id, ad.Ad_id)
	if err != nil {
		return err
	}
	return nil
}

func DelAdByID(db *sql.DB, ad_id uint64) (error) {
	_, err := db.Exec("DELETE FROM ad WHERE ad_id = $1", ad_id)
	if err != nil {
		return err
	}
	return nil
}

func AddView(db *sql.DB, user_id uint64, ad_id uint64) (error) {
	_, err := db.Exec("INSERT INTO views (user_id, ad_id) VALUES ($1, $2) ON CONFLICT DO NOTHING", user_id, ad_id)
	if err != nil {
		return err
	}
	return nil
}

func AddFavorites(db *sql.DB, user_id uint64, ad_id uint64) (error) {
	_, err := db.Exec("INSERT INTO favorites (user_id, ad_id) VALUES ($1, $2) ON CONFLICT DO NOTHING", user_id, ad_id)
	if err != nil {
		return err
	}
	return nil
}

func DelFavorites(db *sql.DB, user_id uint64, ad_id uint64) (error) {
	_, err := db.Exec("DELETE FROM favorites WHERE user_id = $1 AND ad_id = $2", user_id, ad_id)
	if err != nil {
		return err
	}
	return nil
}

func AddFeedback(db *sql.DB, feedback Feedback) (uint64, error) {
	var feedback_id uint64
	err := db.QueryRow("INSERT INTO feedback (user_id, writer_id, comment, rating) " +
		"VALUES ($1, $2, $3, $4) RETURNING feedback_id", feedback.User_id, feedback.Writer_id, 
		feedback.Comment, feedback.Rating).Scan(&feedback_id)
	if err != nil {
		return 0, err
	}
	return feedback_id, nil
}


package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"

	"github.com/gorilla/mux"

	"src/db"
)
 

func handleError(w http.ResponseWriter, err error, statusCode int, message string) {
    log.Panicln(err)
    w.WriteHeader(statusCode)
    w.Write([]byte(fmt.Sprintf(`{"message": "%s"}`, message)))
}

func getTypes(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    conn, err := db.Conn()
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    defer conn.Close()
    types, err := db.GetAllTypes(conn)
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    response, err := json.Marshal(types)
	if err != nil {
		handleError(w, err, http.StatusInternalServerError, "server error")
		return
	}
    w.WriteHeader(http.StatusOK)
    w.Write(response)
}

func getModels(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    conn, err := db.Conn()
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    defer conn.Close()
    models, err := db.GetAllModels(conn)
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    response, err := json.Marshal(models)
	if err != nil {
		handleError(w, err, http.StatusInternalServerError, "server error")
		return
	}
    w.WriteHeader(http.StatusOK)
    w.Write(response)
}

func getColors(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    conn, err := db.Conn()
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    defer conn.Close()
    colors, err := db.GetAllColors(conn)
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    response, err := json.Marshal(colors)
	if err != nil {
		handleError(w, err, http.StatusInternalServerError, "server error")
		return
	}
    w.WriteHeader(http.StatusOK)
    w.Write(response)
}

func getAdByID(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    pathParams := mux.Vars(r)
    var adID uint64 = 0
    var err error
    if val, ok := pathParams["adID"]; ok {
        adID, err = strconv.ParseUint(val, 10, 64)
        if err != nil {
            handleError(w, err, http.StatusBadRequest, "need a number")
            return
        }
    }
    conn, err := db.Conn()
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    defer conn.Close()
    ads, err := db.GetAdByID(conn, adID)
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    response, err := json.Marshal(ads)
	if err != nil {
		handleError(w, err, http.StatusInternalServerError, "server error")
		return
	}
    w.WriteHeader(http.StatusOK)
    w.Write(response)
}

func getAdsWithFilters(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    params := r.URL.Query()
    filters := make(map[string]string)
    if val := params.Get("models"); val != "" {
        filters["model_id"] = val
    }
    if val := params.Get("types"); val != "" {
        filters["model_id"] = val
    }
    if val := params.Get("colors"); val != "" {
        filters["model_id"] = val
    }
    var page uint64 = 0
    if val := params.Get("page"); val != "" {
        var err error
        page, err = strconv.ParseUint(val, 10, 64)
        if err != nil {
            handleError(w, err, http.StatusBadRequest, "page is a uint number!")
            return
        }
    }
    pairs := []string{}
    for key, value := range filters {
        pairs = append(pairs, fmt.Sprintf("%s IN %s", key, value))
    }
    sfilters := strings.Join(pairs, " AND ")
    conn, err := db.Conn()
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    defer conn.Close()
    ads, err := db.GetAdsWithFilters(conn, sfilters, page)
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    response, err := json.Marshal(ads)
	if err != nil {
		handleError(w, err, http.StatusInternalServerError, "server error")
		return
	}
    w.WriteHeader(http.StatusOK)
    w.Write(response)
}

func getViews(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    pathParams := mux.Vars(r)
    var adID uint64 = 0
    var err error
    if val, ok := pathParams["adID"]; ok {
        adID, err = strconv.ParseUint(val, 10, 64)
        if err != nil {
            handleError(w, err, http.StatusBadRequest, "need a positive number")
            return
        }
    }
    conn, err := db.Conn()
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    defer conn.Close()
    views, err := db.GetViews(conn, adID)
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    response, err := json.Marshal(views)
	if err != nil {
		handleError(w, err, http.StatusInternalServerError, "server error")
		return
	}
    w.WriteHeader(http.StatusOK)
    w.Write(response)
}

func getFavorites(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    pathParams := mux.Vars(r)
    var userID uint64 = 0
    var err error
    if val, ok := pathParams["userID"]; ok {
        userID, err = strconv.ParseUint(val, 10, 64)
        if err != nil {
            handleError(w, err, http.StatusBadRequest, "need a positive number")
            return
        }
    }
    conn, err := db.Conn()
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    defer conn.Close()
    favorites, err := db.GetFavorites(conn, userID)
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    response, err := json.Marshal(favorites)
	if err != nil {
		handleError(w, err, http.StatusInternalServerError, "server error")
		return
	}
    w.WriteHeader(http.StatusOK)
    w.Write(response)
}

func getUserInfo(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    pathParams := mux.Vars(r)
    var userID uint64 = 0
    var err error
    if val, ok := pathParams["userID"]; ok {
        userID, err = strconv.ParseUint(val, 10, 64)
        if err != nil {
            handleError(w, err, http.StatusBadRequest, "need a positive number")
            return
        }
    }
    conn, err := db.Conn()
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    defer conn.Close()
    users, err := db.GetUserInfo(conn, userID)
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    response, err := json.Marshal(users)
	if err != nil {
		handleError(w, err, http.StatusInternalServerError, "server error")
		return
	}
    w.WriteHeader(http.StatusOK)
    w.Write(response)
}

func getFeedbacks(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    pathParams := mux.Vars(r)
    var userID uint64 = 0
    var err error
    if val, ok := pathParams["userID"]; ok {
        userID, err = strconv.ParseUint(val, 10, 64)
        if err != nil {
            handleError(w, err, http.StatusBadRequest, "need a positive number")
            return
        }
    }
    conn, err := db.Conn()
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    defer conn.Close()
    fb, err := db.GetFeedbacks(conn, userID)
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    response, err := json.Marshal(fb)
	if err != nil {
		handleError(w, err, http.StatusInternalServerError, "server error")
		return
	}
    w.WriteHeader(http.StatusOK)
    w.Write(response)
}

func getNotifications(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    pathParams := mux.Vars(r)
    var userID uint64 = 0
    var err error
    if val, ok := pathParams["userID"]; ok {
        userID, err = strconv.ParseUint(val, 10, 64)
        if err != nil {
            handleError(w, err, http.StatusBadRequest, "need a positive number")
            return
        }
    }
    conn, err := db.Conn()
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    defer conn.Close()
    notifications, err := db.GetNotifications(conn, userID)
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    response, err := json.Marshal(notifications)
	if err != nil {
		handleError(w, err, http.StatusInternalServerError, "server error")
		return
	}
    w.WriteHeader(http.StatusOK)
    w.Write(response)
}

func addAd(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    err := r.ParseForm()
    if err != nil {
        handleError(w, err, http.StatusBadRequest, "can't read request data")
        return
    }
    
    decoder := json.NewDecoder(r.Body)
    var ad db.Ad
    ad.Ad_id = 0
	err = decoder.Decode(&ad)
	if err != nil {
		http.Error(w, fmt.Sprintf("Invalid request body %s", err) , http.StatusBadRequest)
		return
	}
    conn, err := db.Conn()
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    defer conn.Close()
    ad_id, err := db.AddAd(conn, ad)
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    w.WriteHeader(http.StatusOK)
    w.Write([]byte(fmt.Sprintf(`{"message": "success", "ad_id": %d}`, ad_id)))
}

func updateAdInfo(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    err := r.ParseForm()
    if err != nil {
        handleError(w, err, http.StatusBadRequest, "can't read request data")
        return
    }
    
    decoder := json.NewDecoder(r.Body)
    var ad db.Ad

	err = decoder.Decode(&ad)
	if err != nil {
		http.Error(w, fmt.Sprintf("Invalid request body %s", err) , http.StatusBadRequest)
		return
	}
    conn, err := db.Conn()
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    defer conn.Close()
    err = db.UpdateAdInfo(conn, ad)
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    w.WriteHeader(http.StatusOK)
    w.Write([]byte(fmt.Sprintf(`{"message": "success"}`)))
}

func delAd(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    pathParams := mux.Vars(r)
    var adID uint64 = 0
    var err error
    if val, ok := pathParams["adID"]; ok {
        adID, err = strconv.ParseUint(val, 10, 64)
        if err != nil {
            handleError(w, err, http.StatusBadRequest, "need a number")
            return
        }
    }
    conn, err := db.Conn()
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    defer conn.Close()
    err = db.DelAdByID(conn, adID)
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    
    w.WriteHeader(http.StatusOK)
    w.Write([]byte(fmt.Sprintf(`{"message": "success"}`)))
}

func addView(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    err := r.ParseForm()
    if err != nil {
        handleError(w, err, http.StatusBadRequest, "can't read request data")
        return
    }
    decoder := json.NewDecoder(r.Body)
    view := struct {
        User_id uint64
        Ad_id uint64
    }{}
	err = decoder.Decode(&view)
	if err != nil {
		http.Error(w, fmt.Sprintf("Invalid request body %s", err) , http.StatusBadRequest)
		return
	}
    conn, err := db.Conn()
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    defer conn.Close()
    err = db.AddView(conn, view.User_id, view.Ad_id)
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    w.WriteHeader(http.StatusOK)
    w.Write([]byte(fmt.Sprintf(`{"message": "success"}`)))
}

func addFavorites(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    err := r.ParseForm()
    if err != nil {
        handleError(w, err, http.StatusBadRequest, "can't read request data")
        return
    }
    decoder := json.NewDecoder(r.Body)
    favorites := struct {
        User_id uint64
        Ad_id uint64
    }{}
	err = decoder.Decode(&favorites)
	if err != nil {
		http.Error(w, fmt.Sprintf("Invalid request body %s", err) , http.StatusBadRequest)
		return
	}
    conn, err := db.Conn()
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    defer conn.Close()
    err = db.AddFavorites(conn, favorites.User_id, favorites.Ad_id)
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    w.WriteHeader(http.StatusOK)
    w.Write([]byte(fmt.Sprintf(`{"message": "success"}`)))
}

func delFavorites(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    err := r.ParseForm()
    if err != nil {
        handleError(w, err, http.StatusBadRequest, "can't read request data")
        return
    }
    decoder := json.NewDecoder(r.Body)
    favorites := struct {
        User_id uint64
        Ad_id uint64
    }{}
	err = decoder.Decode(&favorites)
	if err != nil {
		http.Error(w, fmt.Sprintf("Invalid request body %s", err) , http.StatusBadRequest)
		return
	}
    conn, err := db.Conn()
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    defer conn.Close()
    err = db.DelFavorites(conn, favorites.User_id, favorites.Ad_id)
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    w.WriteHeader(http.StatusOK)
    w.Write([]byte(fmt.Sprintf(`{"message": "success"}`)))
}

func addFeedback(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    err := r.ParseForm()
    if err != nil {
        handleError(w, err, http.StatusBadRequest, "can't read request data")
        return
    }
    decoder := json.NewDecoder(r.Body)
    var feedback db.Feedback
    feedback.Feedback_id = 0
	err = decoder.Decode(&feedback)
	if err != nil {
		http.Error(w, fmt.Sprintf("Invalid request body %s", err) , http.StatusBadRequest)
		return
	}
    conn, err := db.Conn()
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    defer conn.Close()
    feedback_id, err := db.AddFeedback(conn, feedback)
    if err != nil {
        handleError(w, err, http.StatusInternalServerError, "server error")
        return
    }
    w.WriteHeader(http.StatusOK)
    w.Write([]byte(fmt.Sprintf(`{"message": "success", "feedback_id": %d}`, feedback_id)))
}


func main() {
    r := mux.NewRouter()

    api := r.PathPrefix("/api/v1").Subrouter()

	api.HandleFunc("/models", getModels).Methods(http.MethodGet)
	api.HandleFunc("/types", getTypes).Methods(http.MethodGet)
	api.HandleFunc("/colors", getColors).Methods(http.MethodGet)
	api.HandleFunc("/ad/{adID}", getAdByID).Methods(http.MethodGet)
    // localhost:8080/api/v1/ads/filters?models=(1)&page=1
	api.HandleFunc("/ads/filters", getAdsWithFilters).Methods(http.MethodGet)
	api.HandleFunc("/views/{adID}", getViews).Methods(http.MethodGet)
	api.HandleFunc("/favorites/{userID}", getFavorites).Methods(http.MethodGet)
	api.HandleFunc("/favorites", addFavorites).Methods(http.MethodPost)
	api.HandleFunc("/favorites", delFavorites).Methods(http.MethodDelete)
	api.HandleFunc("/user/{userID}", getUserInfo).Methods(http.MethodGet)
	api.HandleFunc("/feedbacks/{userID}", getFeedbacks).Methods(http.MethodGet)
	api.HandleFunc("/notifications/{userID}", getNotifications).Methods(http.MethodGet)
	api.HandleFunc("/ad", addAd).Methods(http.MethodPost)
	api.HandleFunc("/ad", updateAdInfo).Methods(http.MethodPut)
	api.HandleFunc("/ad/{adID}", delAd).Methods(http.MethodDelete)
	api.HandleFunc("/views", addView).Methods(http.MethodPost)
	api.HandleFunc("/feedbacks", addFeedback).Methods(http.MethodPost)

    log.Fatal(http.ListenAndServe(":8080", r))
}


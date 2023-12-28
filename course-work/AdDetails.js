import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';

const AdDetails = () => {
  const { adID } = useParams(); // Получаем параметр adID из URL

  // Здесь можно получить подробную информацию об объявлении с использованием adID
  // Например, можно сделать запрос на сервер, чтобы получить данные по конкретному adID

  const [adDetails, setAdDetails] = useState(null);

  useEffect(() => {
    const fetchAdDetails = async () => {
      try {
        const response = await fetch(`http://45.67.32.34:8080/api/v1/ad/${adID}`);
        if (!response.ok) {
          throw new Error('Ошибка получения данных');
        }
        const data = await response.json();
        setAdDetails(data[0]);
      } catch (error) {
        console.error('Ошибка при получении подробностей объявления:', error);
      }
    };

    fetchAdDetails();
  }, [adID]);
  const addView = async (userId, adId) => {
    try {
      const response = await fetch('http://45.67.32.34:8080/api/v1/views', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          User_id:userId,
          Ad_id:adId
        }),
      });

      if (!response.ok) {
        throw new Error('Ошибка добавления в избранное');
      }

      console.log('Объявление добавлено в избранное!');
    } catch (error) {
      console.error('Ошибка при добавлении в избранное:', error);
    }
  };
  const addToFavorites = async (userId, adId) => {
    try {
      const response = await fetch('http://45.67.32.34:8080/api/v1/favorites', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          User_id:userId,
          Ad_id:adId
        }),
      });

      if (!response.ok) {
        throw new Error('Ошибка добавления в избранное');
      }

      console.log('Объявление добавлено в избранное!');
    } catch (error) {
      console.error('Ошибка при добавлении в избранное:', error);
    }
  };
  const removeFromFavorites = async (userId, adId) => {
    try {
      const response = await fetch('http://45.67.32.34:8080/api/v1/favorites', {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          User_id:userId,
          Ad_id:adId
        }),
      });

      if (!response.ok) {
        throw new Error('Ошибка при удалении из избранного');
      }

      console.log('Объявление удалено из избранного!');
    } catch (error) {
      console.error('Ошибка при удалении из избранного:', error);
    }
  };
  
  if (!adDetails) {
    return <div>Loading...</div>; // Отображаем загрузку, пока данные не загружены
  }
  addView(1, adDetails.Ad_id)
  // Отображение подробной информации об объявлении
  return (
    <div>
      <h1>Подробности объявления</h1>
      <p>ID объявления: {adDetails.Ad_id}</p>
      <p>Название: {adDetails.Title}</p>
      <p>Цена: {adDetails.Price}</p>
      <p>Описание: {adDetails.Description}</p>
      <p>Местоположение: {adDetails.Location}</p>
      <p>Фото: {adDetails.Photo}</p>
      <p>Модель: {adDetails.Model_id}</p>
      <p>Тип: {adDetails.Type_id}</p>
      <p>Цвет: {adDetails.Color_id}</p>
      <p>Количество Просмотров: 12</p>
      <button onClick={() => addToFavorites(1, adDetails.Ad_id)}>
        Добавить в избранное
      </button>
      <button onClick={() => removeFromFavorites(1, adDetails.Ad_id)}>
        Удалить из избранного
      </button>
    </div>
  );
};

export default AdDetails;
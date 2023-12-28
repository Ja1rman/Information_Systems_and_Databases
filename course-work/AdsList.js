import React, { useEffect, useState } from 'react';

const AdsList = () => {
  const [ads, setAds] = useState([]);

  useEffect(() => {
    const fetchAds = async () => {
      try {
        const response = await fetch('http://45.67.32.34:8080/api/v1/ads/filters?page=1');
        if (!response.ok) {
          throw new Error('Ошибка получения данных');
        }
        const data = await response.json();
        setAds(data);
      } catch (error) {
        console.error('Ошибка при получении объявлений:', error);
      }
    };

    fetchAds();
  }, []);

  return (
    <div>
      <h1>Список объявлений</h1>
      <ul>
        {ads.map((ad) => (
          <li key={ad.Ad_id}>
            <a href={`/ads/${ad.Ad_id}`}>Название: {ad.Title}</a>
            <p>Цена: {ad.Price}</p>
        </li>
        ))}
      </ul>
    </div>
  );
};

export default AdsList;